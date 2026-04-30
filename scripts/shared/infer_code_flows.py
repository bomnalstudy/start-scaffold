#!/usr/bin/env python3
import argparse
import json
import os
from datetime import datetime, timezone
from pathlib import Path

from ai_flow_code_map import build_component_context, estimate_file_map_chars
from ai_flow_io import chunked, clear_stale_lock, compact_batch as compact_batch_result, compact_flow, run_ai, save_batch, save_merge, save_prompt
from ai_flow_normalize import normalize_flow
from ai_flow_progress import completed_batch_count, flow_from_latest_merge, progress


SUPPORTING_ROLES = {"docs", "skill"}
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
TARGET_UNIT_MAP_CHARS = 2600


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


def attach_component_files(flow: dict, components: list[dict], root: Path, files_per_unit: int) -> list[dict]:
    files_by_component: dict[str, list[str]] = {}
    for file in flow.get("files", []):
        if file.get("role") in SUPPORTING_ROLES:
            continue
        path = str(file.get("path", ""))
        if path.lower().endswith(".md") or is_one_off_path(path):
            continue
        files_by_component.setdefault(file.get("component", ""), []).append(path)
    enriched = []
    for component in components:
        all_files = [
            path for path in files_by_component.get(component["name"], component.get("sampleFiles", []))
            if path
        ]
        file_groups = fixed_file_groups(all_files, files_per_unit) if files_per_unit > 0 else auto_file_groups(root, all_files)
        for index, files in enumerate(file_groups, start=1):
            next_component = dict(component)
            next_component["name"] = f"{component['name']} part {index}"
            next_component["sampleFiles"] = files
            next_component["fileCount"] = len(files)
            enriched.append(next_component)
    return enriched


def fixed_file_groups(files: list[str], files_per_unit: int) -> list[list[str]]:
    return [[item["path"] for item in group] for group in chunked([{"path": path} for path in files], max(1, files_per_unit))]


def auto_file_groups(root: Path, files: list[str]) -> list[list[str]]:
    groups = []
    current = []
    current_chars = 0
    for path in files:
        estimate = max(120, estimate_file_map_chars(root, path))
        if current and current_chars + estimate > TARGET_UNIT_MAP_CHARS:
            groups.append(current)
            current = []
            current_chars = 0
        current.append(path)
        current_chars += estimate
    if current:
        groups.append(current)
    return groups


def build_dependency_context(flow: dict, component_names: set[str], max_edges: int) -> str:
    lines = []
    for edge in flow.get("dependencies", []):
        if edge["from"] in component_names and edge["to"] in component_names:
            lines.append(f"- {edge['from']} -> {edge['to']} ({edge['count']} refs)")
    return "\n".join(lines[:max_edges]) if lines else "- no internal import links detected between selected areas"


def build_batch_prompt(flow: dict, root: Path, language: str, components: list[dict], max_files_per_component: int, batch_index: int) -> str:
    component_names = {item["name"] for item in components}
    dependency_context = build_dependency_context(flow, component_names, 15)
    component_context = build_component_context(root, components, max_files_per_component, 900)
    return f"""
You are inspecting one compact local code map before a final flowchart is assembled.

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
- Return at most 2 candidate nodes per component and 6 candidate nodes for this batch.
- If this batch does not show a runtime step, return an empty candidates array.
- Include files and evidence for every candidate node.
- Write summary and responsibilities for a non-programmer. Do not use function names, SQL, table names, or file paths there unless you explain what they mean.
- Put code identifiers only in evidence. If you must use a technical term such as heartbeat, job, queue, table, API, or database, add a terms item that explains it simply.
- The code evidence below is a repo map: symbols, routes, imports, and detected side-effect signals. Prefer those structured signals over guessing from filenames.

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

Compact code map in this batch:
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
- Prefer one main flow with 6 to 12 nodes while batches are still running.
- Keep common flowchart semantics: start, process, decision, io, data, subprocess, document, end.
- Every node must include files and evidence.
- Edges must explain the handoff or condition.
- Keep good existing nodes from the current flow.
- Add, replace, or connect nodes only when the next batch gives concrete evidence.
- This is an intermediate result, so it can be incomplete, but it must remain valid JSON.
- Keep the JSON compact. Do not expand descriptions unless the new batch changes the meaning.
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


def write_partial_flow(flow_path: Path, base_flow: dict, raw_flow: dict, language: str, completed: int, total: int, plan_key: str, message: str = "") -> None:
    partial = dict(base_flow)
    partial["flows"] = normalize_flow(raw_flow)
    partial["flowSource"] = "local-ai"
    partial["flowGeneratedAt"] = datetime.now(timezone.utc).isoformat()
    partial["flowLanguage"] = language
    partial["flowComplete"] = False
    partial["flowProgress"] = progress("running", language, completed, total, plan_key, message or f"AI batch {completed} of {total} merged.")
    write_flow(flow_path, partial)
    write_memory(flow_path, partial)


def write_progress_only(flow_path: Path, base_flow: dict, language: str, completed: int, total: int, plan_key: str, message: str) -> None:
    partial = flow_from_latest_merge(flow_path, base_flow, language, completed, total, plan_key)
    if not partial.get("flows"):
        memory = load_memory(flow_path)
        if memory and memory.get("flows") and memory.get("flowLanguage") == language:
            partial = memory
    partial["flowSource"] = "local-ai"
    partial["flowLanguage"] = language
    partial["flowComplete"] = False
    partial["flowProgress"] = progress("running", language, completed, total, plan_key, message)
    write_flow(flow_path, partial)
    if partial.get("flows"):
        write_memory(flow_path, partial)


def infer_and_merge_sequentially(command: str, flow: dict, flow_path: Path, root: Path, language: str, components: list[dict], max_files: int, batch_size: int, timeout: int, work_dir: Path, plan_key: str) -> dict:
    memory = load_memory(flow_path)
    memory_progress = memory.get("flowProgress", {}) if memory else {}
    can_reuse_memory = bool(
        memory
        and memory.get("flowLanguage") == language
        and memory_progress.get("planKey") == plan_key
        and int(memory_progress.get("completedBatches", 0) or 0) > 0
    )
    current = {"flows": memory.get("flows", [])} if can_reuse_memory else None
    batches = chunked(components, batch_size)
    if not batches:
        raise RuntimeError("No batches were available to infer.")
    completed_before = completed_batch_count(memory, language, len(batches), plan_key)
    if completed_before >= len(batches) and current:
        return current
    write_progress_only(flow_path, flow, language, completed_before, len(batches), plan_key, "AI flow inference started.")
    for index, batch in enumerate(batches, start=1):
        if index <= completed_before:
            continue
        write_progress_only(flow_path, flow, language, index - 1, len(batches), plan_key, f"AI batch {index} of {len(batches)} is reading code.")
        prompt = build_batch_prompt(flow, root, language, batch, max_files, index)
        save_prompt(work_dir, f"prompt-batch-{index:03}.md", prompt)
        batch_result = run_ai(command, prompt, timeout)
        batch_result["componentNames"] = [item["name"] for item in batch]
        save_batch(work_dir, index, batch_result)
        print(f"AI flow batch {index}: {len(batch)} components")
        write_progress_only(flow_path, flow, language, index - 1, len(batches), plan_key, f"AI batch {index} of {len(batches)} is merging into the flowchart.")
        prompt = build_merge_prompt(flow, language, current, batch_result)
        save_prompt(work_dir, f"prompt-merge-{index:03}.md", prompt)
        try:
            current = run_ai(command, prompt, timeout)
            save_merge(work_dir, index, current)
            write_partial_flow(flow_path, flow, current, language, index, len(batches), plan_key)
            print(f"AI flow merge {index}/{len(batches)}: saved partial flow")
        except Exception as error:
            if not current:
                raise
            write_partial_flow(flow_path, flow, current, language, index, len(batches), plan_key, f"AI batch {index} of {len(batches)} was scanned, but merge was skipped after a local AI error.")
            print(f"AI flow merge {index}/{len(batches)} skipped: {error}")
    return current


def main() -> int:
    parser = argparse.ArgumentParser(description="Use a local AI CLI to infer real code workflows.")
    parser.add_argument("--root", default=".")
    parser.add_argument("--flow-path", default="docs/generated/code-flow.json")
    parser.add_argument("--language", default="ko")
    parser.add_argument("--max-components", type=int, default=0)
    parser.add_argument("--max-files-per-component", type=int, default=0)
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
        root,
        args.max_files_per_component,
    )
    batch_size = max(1, args.batch_size)
    total_batches = len(chunked(components, batch_size))
    unit_mode = f"fixedFiles={args.max_files_per_component}" if args.max_files_per_component > 0 else f"autoMapChars={TARGET_UNIT_MAP_CHARS}"
    plan_key = f"repo-map-v2:{unit_mode}:batch={batch_size}:units={len(components)}"
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
            batch_size,
            args.timeout,
            work_dir,
            plan_key,
        )
    except Exception as error:
        failed_flow = read_json(flow_path) if flow_path.exists() else dict(flow)
        completed = completed_batch_count(failed_flow, args.language, total_batches, plan_key)
        failed_flow["flowSource"] = "local-ai"
        failed_flow["flowLanguage"] = args.language
        failed_flow["flowComplete"] = False
        failed_flow["flowProgress"] = progress("failed", args.language, completed, total_batches, plan_key, "AI flow inference failed.", str(error))
        write_flow(flow_path, failed_flow)
        raise
    finally:
        lock_path.unlink(missing_ok=True)

    flow["flows"] = normalize_flow(raw)
    flow["flowSource"] = "local-ai"
    flow["flowGeneratedAt"] = datetime.now(timezone.utc).isoformat()
    flow["flowLanguage"] = args.language
    flow["flowComplete"] = True
    flow["flowProgress"] = progress("completed", args.language, total_batches, total_batches, plan_key, "AI flow inference completed.")
    write_flow(flow_path, flow)
    write_memory(flow_path, flow)

    print(f"AI inferred flows: {len(flow['flows'])}")
    print(f"Flow: {flow_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
