#!/usr/bin/env python3
import argparse
import json
import os
from datetime import datetime, timezone
from pathlib import Path

from ai_flow_io import chunked, clear_stale_lock, compact_batch as compact_batch_result, compact_flow, run_ai, save_batch, save_merge, save_prompt


SUPPORTING_ROLES = {"docs", "skill"}
FLOW_NODE_TYPES = {"start", "end", "process", "decision", "data", "io", "document", "subprocess"}
PRODUCT_ROLES = {"entrypoint", "ui", "backend", "service", "orchestration", "repository", "database", "domain", "security"}
ONE_OFF_MARKERS = {
    "backfill",
    "cleanup",
    "fix-",
    "migration",
    "one-off",
    "rerun",
    "seed",
    "temporary",
    "tmp",
}


def read_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8-sig"))


def write_flow(flow_path: Path, flow: dict) -> None:
    payload = json.dumps(flow, ensure_ascii=False, indent=2) + "\n"
    tmp_path = flow_path.with_suffix(".json.tmp")
    tmp_path.write_text(payload, encoding="utf-8")
    tmp_path.replace(flow_path)
    data_js_path = flow_path.with_name("code-flow-data.js")
    data_js_tmp = data_js_path.with_suffix(".js.tmp")
    data_js_tmp.write_text("window.CODE_FLOW_DATA = " + json.dumps(flow, ensure_ascii=False, indent=2) + ";\n", encoding="utf-8")
    data_js_tmp.replace(data_js_path)


def memory_path_for(flow_path: Path) -> Path:
    return flow_path.with_name("code-flow-memory.json")


def load_memory(flow_path: Path) -> dict | None:
    memory_path = memory_path_for(flow_path)
    if not memory_path.exists():
        return None
    return json.loads(memory_path.read_text(encoding="utf-8-sig"))


def write_memory(flow_path: Path, flow: dict) -> None:
    memory_path = memory_path_for(flow_path)
    tmp_path = memory_path.with_suffix(".json.tmp")
    tmp_path.write_text(json.dumps(flow, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    tmp_path.replace(memory_path)


def acquire_lock(work_dir: Path) -> Path:
    work_dir.mkdir(parents=True, exist_ok=True)
    lock_path = work_dir / "infer.lock"
    clear_stale_lock(lock_path)
    try:
        handle = os.open(str(lock_path), os.O_CREAT | os.O_EXCL | os.O_WRONLY)
    except FileExistsError as error:
        raise RuntimeError(f"Flow inference is already running: {lock_path}") from error
    os.write(handle, str(os.getpid()).encode("utf-8"))
    os.close(handle)
    return lock_path


def score_component(flow: dict, component: dict) -> int:
    refs = 0
    for edge in flow.get("dependencies", []):
        if edge["from"] == component["name"] or edge["to"] == component["name"]:
            refs += edge["count"]
    role = component.get("primaryRole", "")
    role_bonus = {
        "entrypoint": 700,
        "orchestration": 620,
        "backend": 560,
        "service": 520,
        "ui": 460,
        "repository": 420,
        "database": 360,
        "security": 340,
        "automation": 220,
        "verification": 180,
    }.get(role, 120)
    support_penalty = -900 if role in SUPPORTING_ROLES else 0
    app_bonus = 250 if component["name"].startswith("apps/") else 0
    return refs * 35 + role_bonus + app_bonus + component.get("fileCount", 0) + support_penalty


def result_impact_rank(component: dict) -> int:
    name = component["name"].replace("\\", "/")
    role = component.get("primaryRole", "")
    if "/src/" in name or name.endswith("/src"):
        return 0
    if name.startswith("apps/") and role in PRODUCT_ROLES:
        return 1
    if role in {"config", "automation", "verification"}:
        return 2
    if role in SUPPORTING_ROLES or name.startswith(("docs/", "worklogs/")) or name.endswith(".md"):
        return 4
    return 3


def is_one_off_path(value: str) -> bool:
    normalized = value.replace("\\", "/").lower()
    return any(marker in normalized for marker in ONE_OFF_MARKERS)


def selected_components(flow: dict, max_components: int) -> list[dict]:
    candidates = [
        item
        for item in flow.get("components", [])
        if item.get("primaryRole") not in SUPPORTING_ROLES
        and not is_one_off_path(item.get("name", ""))
    ]
    ranked = sorted(candidates, key=lambda item: (result_impact_rank(item), -score_component(flow, item), item["name"]))
    return ranked if max_components <= 0 else ranked[:max_components]


def attach_component_files(flow: dict, components: list[dict], files_per_unit: int) -> list[dict]:
    files_by_component: dict[str, list[str]] = {}
    for file in flow.get("files", []):
        if file.get("role") in SUPPORTING_ROLES:
            continue
        path = str(file.get("path", ""))
        if path.lower().endswith(".md") or is_one_off_path(path):
            continue
        files_by_component.setdefault(file.get("component", ""), []).append(path)
    enriched = []
    unit_size = max(1, files_per_unit)
    for component in components:
        all_files = [
            path for path in files_by_component.get(component["name"], component.get("sampleFiles", []))
            if path
        ]
        for index, file_group in enumerate(chunked([{"path": path} for path in all_files], unit_size), start=1):
            files = [item["path"] for item in file_group]
            next_component = dict(component)
            next_component["name"] = f"{component['name']} part {index}"
            next_component["sampleFiles"] = files
            next_component["fileCount"] = len(files)
            enriched.append(next_component)
    return enriched


def read_excerpt(root: Path, rel_path: str, max_chars: int) -> str:
    path = root / rel_path
    try:
        text = path.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return ""
    return text[:max_chars]


def build_component_context(root: Path, components: list[dict], max_files_per_component: int, max_chars: int) -> str:
    blocks = []
    for component in components:
        file_blocks = []
        files = component.get("sampleFiles", [])
        selected_files = files if max_files_per_component <= 0 else files[:max_files_per_component]
        for rel in selected_files:
            excerpt = read_excerpt(root, rel, max_chars)
            if excerpt:
                file_blocks.append(f"--- {rel} ---\n{excerpt}")
        blocks.append(
            "\n".join(
                [
                    f"## {component['name']}",
                    f"role: {component.get('primaryRole')}",
                    f"fileCount: {component.get('fileCount')}",
                    f"selectedFiles: {selected_files}",
                    "\n\n".join(file_blocks) if file_blocks else "(no readable excerpts)",
                ]
            )
        )
    return "\n\n".join(blocks)


def build_dependency_context(flow: dict, component_names: set[str], max_edges: int) -> str:
    lines = []
    for edge in flow.get("dependencies", []):
        if edge["from"] in component_names and edge["to"] in component_names:
            lines.append(f"- {edge['from']} -> {edge['to']} ({edge['count']} refs)")
    return "\n".join(lines[:max_edges]) if lines else "- no internal import links detected between selected areas"


def build_batch_prompt(flow: dict, root: Path, language: str, components: list[dict], max_files_per_component: int, batch_index: int) -> str:
    component_names = {item["name"] for item in components}
    dependency_context = build_dependency_context(flow, component_names, 40)
    component_context = build_component_context(root, components, max_files_per_component, 2200)
    return f"""
You are inspecting one small batch of files before a final flowchart is assembled.

Audience:
- The reader may not know programming.

Language:
- Write every JSON string in {language}.
- If language is ko, write labels, summaries, evidence, edge labels, and edge reasons in natural Korean.
- Use English only for file paths, function names, commands, API names, and exact identifiers.

Rules:
- Return JSON only.
- Markdown files are supporting context for vibe-coding work, not product output. Do not create flow nodes from .md files unless there is no code evidence.
- Do not invent steps outside this batch.
- Do not make generic role summaries.
- Extract concrete workflow candidates: starts, inputs, decisions, actions, data access, validation, and endings.
- Return at most 3 candidate nodes for this batch.
- If this batch does not show a runtime step, return an empty candidates array.
- Include files and evidence for every candidate node.
- Write summary and responsibilities for a non-programmer. Do not use function names, SQL, table names, or file paths there unless you explain what they mean.
- Put code identifiers only in evidence. If you must use a technical term such as heartbeat, job, queue, table, API, or database, add a terms item that explains it simply.

Return this exact JSON shape:
{{
  "batch": {batch_index},
  "candidates": [
    {{
      "id": "stable-kebab-id",
      "type": "start|process|decision|io|data|subprocess|document|end",
      "label": "short box label",
      "role": "entrypoint|ui|backend|security|orchestration|service|domain|repository|database|automation|verification|config|project",
      "summary": "what this exact step appears to do, explained for a non-programmer",
      "responsibilities": ["plain-language thing this step does for the product or operator"],
      "terms": ["technical term: simple meaning in this project"],
      "files": ["relative/path.ts"],
      "evidence": ["specific filename, function, route, command, import, or text evidence"]
    }}
  ],
  "handoffs": [
    {{
      "from": "candidate-id",
      "to": "candidate-id",
      "label": "condition or handoff",
      "reason": "why these candidates are connected"
    }}
  ]
}}

Project root:
{flow.get("root")}

Dependency hints in this batch:
{dependency_context}

Code evidence in this batch:
{component_context}
""".strip()


def build_merge_prompt(flow: dict, language: str, current_flow: dict | None, next_batch: dict) -> str:
    compact_current = json.dumps(compact_flow(current_flow), ensure_ascii=False, indent=2)
    compact_next_batch = json.dumps(compact_batch_result(next_batch), ensure_ascii=False, indent=2)
    return f"""
You are incrementally assembling a true flowchart from one batch at a time.

Audience:
- The reader may not know programming.

Language:
- Write every JSON string in {language}.
- If language is ko, keep all user-facing text in natural Korean.

Rules:
- Return JSON only.
- Keep Markdown-derived information behind code evidence; do not let .md files decide the main result flow.
- Use only the current flow and the next batch result.
- Build runtime or work-process flows, not a dependency map.
- Prefer one main flow with 8 to 16 nodes.
- Keep common flowchart semantics: start, process, decision, io, data, subprocess, document, end.
- Every node must include files and evidence.
- Edges must explain the handoff or condition.
- Keep good existing nodes from the current flow.
- Add, replace, or connect nodes only when the next batch gives concrete evidence.
- This is an intermediate result, so it can be incomplete, but it must remain valid JSON.
- Write node summaries and responsibilities for a non-programmer who does not know code.
- Do not put function names, SQL, table names, or file paths in summary/responsibilities. Put those in evidence.
- If a technical term is useful, keep it only when terms explains it in simple language.

Return this exact JSON shape:
{{
  "flows": [
    {{
      "id": "main",
      "name": "short workflow name",
      "summary": "one plain sentence about what this workflow does",
      "nodes": [
        {{
          "id": "stable-kebab-id",
          "type": "start|process|decision|io|data|subprocess|document|end",
          "label": "short box label",
          "role": "entrypoint|ui|backend|security|orchestration|service|domain|repository|database|automation|verification|config|project",
          "summary": "what this exact step does, in plain language",
          "responsibilities": ["plain-language thing this step does for the product or operator"],
          "terms": ["technical term: simple meaning in this project"],
          "files": ["relative/path.ts"],
          "evidence": ["concrete evidence from batch results"]
        }}
      ],
      "edges": [
        {{
          "from": "node-id",
          "to": "node-id",
          "label": "condition or handoff label",
          "reason": "why these steps are connected"
        }}
      ]
    }}
  ]
}}

Project root:
{flow.get("root")}

Current flow so far:
{compact_current}

Next batch result:
{compact_next_batch}
""".strip()


def write_partial_flow(flow_path: Path, base_flow: dict, raw_flow: dict) -> None:
    partial = dict(base_flow)
    partial["flows"] = normalize_flow(raw_flow)
    partial["flowSource"] = "local-ai"
    partial["flowGeneratedAt"] = datetime.now(timezone.utc).isoformat()
    partial["flowLanguage"] = base_flow.get("flowLanguage", "ko")
    write_flow(flow_path, partial)
    write_memory(flow_path, partial)


def infer_and_merge_sequentially(command: str, flow: dict, flow_path: Path, root: Path, language: str, components: list[dict], max_files: int, batch_size: int, timeout: int, work_dir: Path) -> dict:
    memory = load_memory(flow_path)
    current = {"flows": memory.get("flows", [])} if memory else None
    for index, batch in enumerate(chunked(components, batch_size), start=1):
        prompt = build_batch_prompt(flow, root, language, batch, max_files, index)
        save_prompt(work_dir, f"prompt-batch-{index:03}.md", prompt)
        batch_result = run_ai(command, prompt, timeout)
        batch_result["componentNames"] = [item["name"] for item in batch]
        save_batch(work_dir, index, batch_result)
        print(f"AI flow batch {index}: {len(batch)} components")
        prompt = build_merge_prompt(flow, language, current, batch_result)
        save_prompt(work_dir, f"prompt-merge-{index:03}.md", prompt)
        current = run_ai(command, prompt, timeout)
        save_merge(work_dir, index, current)
        write_partial_flow(flow_path, flow, current)
        print(f"AI flow merge {index}: saved partial flow")
    if not current:
        raise RuntimeError("No batches were available to infer.")
    return current


def clean_id(value: str, fallback: str) -> str:
    cleaned = "".join(char.lower() if char.isalnum() else "-" for char in value).strip("-")
    while "--" in cleaned:
        cleaned = cleaned.replace("--", "-")
    return cleaned or fallback


def normalize_flow(raw: dict) -> list[dict]:
    flows = raw.get("flows")
    if not isinstance(flows, list) or not flows:
        raise RuntimeError("AI JSON is missing flows.")
    normalized = []
    for flow_index, item in enumerate(flows[:3]):
        nodes = []
        seen = set()
        for node_index, node in enumerate(item.get("nodes", [])[:20]):
            node_id = clean_id(str(node.get("id") or node.get("label") or ""), f"node-{node_index}")
            if node_id in seen:
                node_id = f"{node_id}-{node_index}"
            seen.add(node_id)
            node_type = str(node.get("type", "process")).strip()
            if node_type not in FLOW_NODE_TYPES:
                node_type = "process"
            role = str(node.get("role", "project")).strip()
            nodes.append(
                {
                    "id": node_id,
                    "type": node_type,
                    "label": str(node.get("label") or node_id).strip()[:80],
                    "role": role,
                    "summary": str(node.get("summary", "")).strip()[:500],
                    "responsibilities": [str(text).strip()[:220] for text in node.get("responsibilities", [])[:5] if str(text).strip()],
                    "terms": [str(text).strip()[:220] for text in node.get("terms", [])[:6] if str(text).strip()],
                    "files": [str(path).strip() for path in node.get("files", [])[:8] if str(path).strip()],
                    "evidence": [str(text).strip()[:240] for text in node.get("evidence", [])[:5] if str(text).strip()],
                }
            )
        node_ids = {node["id"] for node in nodes}
        edges = []
        for edge in item.get("edges", [])[:28]:
            source = clean_id(str(edge.get("from", "")), "")
            target = clean_id(str(edge.get("to", "")), "")
            if source in node_ids and target in node_ids:
                edges.append(
                    {
                        "from": source,
                        "to": target,
                        "label": str(edge.get("label", "")).strip()[:80],
                        "reason": str(edge.get("reason", "")).strip()[:260],
                    }
                )
        if nodes:
            normalized.append(
                {
                    "id": clean_id(str(item.get("id", "")), f"flow-{flow_index}"),
                    "name": str(item.get("name") or f"Flow {flow_index + 1}").strip()[:80],
                    "summary": str(item.get("summary", "")).strip()[:500],
                    "nodes": nodes,
                    "edges": edges,
                }
            )
    return normalized


def main() -> int:
    parser = argparse.ArgumentParser(description="Use a local AI CLI to infer real code workflows.")
    parser.add_argument("--root", default=".")
    parser.add_argument("--flow-path", default="docs/generated/code-flow.json")
    parser.add_argument("--language", default="ko")
    parser.add_argument("--max-components", type=int, default=0)
    parser.add_argument("--max-files-per-component", type=int, default=4)
    parser.add_argument("--batch-size", type=int, default=4)
    parser.add_argument("--work-dir", default="docs/generated/code-flow-work")
    parser.add_argument("--ai-command", required=True)
    parser.add_argument("--timeout", type=int, default=240)
    args = parser.parse_args()

    root = Path(args.root).resolve()
    flow_path = (root / args.flow_path).resolve()
    flow = read_json(flow_path)
    flow["flowLanguage"] = args.language
    components = attach_component_files(
        flow,
        selected_components(flow, args.max_components),
        args.max_files_per_component,
    )
    work_dir = (root / args.work_dir).resolve()
    lock_path = acquire_lock(work_dir)
    try:
        raw = infer_and_merge_sequentially(
            args.ai_command,
            flow,
            flow_path,
            root,
            args.language,
            components,
            args.max_files_per_component,
            max(1, args.batch_size),
            args.timeout,
            work_dir,
        )
    finally:
        lock_path.unlink(missing_ok=True)

    flow["flows"] = normalize_flow(raw)
    flow["flowSource"] = "local-ai"
    flow["flowGeneratedAt"] = datetime.now(timezone.utc).isoformat()
    flow["flowLanguage"] = args.language
    write_flow(flow_path, flow)
    write_memory(flow_path, flow)

    print(f"AI inferred flows: {len(flow['flows'])}")
    print(f"Flow: {flow_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
