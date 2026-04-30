#!/usr/bin/env python3
import argparse
import json
import subprocess
import tempfile
from pathlib import Path


def related_edges(flow: dict, component_name: str) -> list[dict]:
    edges = []
    for edge in flow.get("dependencies", []):
        if edge["from"] == component_name or edge["to"] == component_name:
            edges.append(edge)
    return edges[:12]


def read_sample(root: Path, files: list[str]) -> str:
    chunks = []
    for rel in files[:4]:
        path = root / rel
        try:
            text = path.read_text(encoding="utf-8", errors="ignore")[:2200]
        except Exception:
            continue
        chunks.append(f"--- {rel} ---\n{text}")
    return "\n\n".join(chunks)


def build_prompt(flow: dict, component: dict, root: Path, language: str) -> str:
    edges = related_edges(flow, component["name"])
    relation_lines = [
        f"- {edge['from']} -> {edge['to']} ({edge['count']} refs)"
        for edge in edges
    ]
    sample = read_sample(root, component.get("sampleFiles", []))
    return f"""
You are analyzing one node in a code-flow board.

Audience:
- The reader may not know programming.
- The reader wants to understand what this box means while vibe-coding.

Language:
- Write the final JSON values in {language}.

Rules:
- Do not use vague template sentences.
- Do not mention "heuristic", "enrichment", "static analysis", or "component".
- Explain where this code area lives, what it does, why it exists, and how it connects to other areas.
- If the evidence is weak, say what can be inferred from the files and what remains uncertain.
- Be concrete. Mention file names or folder names when useful.
- Return valid JSON text. If you write Korean, make sure it is valid UTF-8 JSON.

Return JSON only with this exact shape:
{{
  "summary": "one plain sentence explaining what this node does",
  "responsibilities": ["2-4 concrete responsibilities"],
  "relationships": ["1-3 concrete relationship explanations"],
  "confidence": "high|medium|low"
}}

Project root:
{flow.get("root")}

Node:
- name: {component["name"]}
- role label from scanner: {component["primaryRole"]}
- fileCount: {component["fileCount"]}
- sampleFiles: {component.get("sampleFiles", [])}

Detected code links:
{chr(10).join(relation_lines) if relation_lines else "- no direct internal import links detected"}

File excerpts:
{sample if sample else "(no readable excerpts)"}
""".strip()


def run_ai(command: str, prompt: str, timeout: int) -> dict:
    with tempfile.NamedTemporaryFile("w", suffix=".md", delete=False, encoding="utf-8") as handle:
        handle.write(prompt)
        prompt_path = handle.name
    try:
        cmd = command.replace("{prompt_file}", prompt_path)
        completed = subprocess.run(
            cmd,
            input=None if "{prompt_file}" in command else prompt.encode("utf-8"),
            capture_output=True,
            shell=True,
            timeout=timeout,
        )
    finally:
        Path(prompt_path).unlink(missing_ok=True)

    if completed.returncode != 0:
        stderr = completed.stderr.decode("utf-8", errors="replace").strip()
        raise RuntimeError(stderr or f"AI command exited with {completed.returncode}")

    try:
        text = completed.stdout.decode("utf-8")
    except UnicodeDecodeError:
        text = completed.stdout.decode("cp949", errors="replace")
    text = text.strip()
    start = text.find("{")
    end = text.rfind("}")
    if start < 0 or end < start:
        raise RuntimeError("AI command did not return JSON.")

    data = json.loads(text[start : end + 1])
    if not isinstance(data.get("summary"), str) or not data["summary"].strip():
        raise RuntimeError("AI JSON is missing summary.")

    return {
        "summary": data["summary"].strip()[:320],
        "responsibilities": [str(item).strip()[:220] for item in data.get("responsibilities", [])[:4] if str(item).strip()],
        "relationships": [str(item).strip()[:260] for item in data.get("relationships", [])[:3] if str(item).strip()],
        "confidence": str(data.get("confidence", "medium")).strip()[:20],
        "analysisSource": "local-ai",
    }


def component_score(flow: dict, component: dict) -> int:
    refs = 0
    for edge in flow.get("dependencies", []):
        if edge["from"] == component["name"] or edge["to"] == component["name"]:
            refs += edge["count"]
    app_bonus = 300 if component["name"].startswith("apps/") else 0
    doc_penalty = -200 if component["primaryRole"] == "docs" else 0
    return refs * 30 + app_bonus + doc_penalty + component["fileCount"]


def main() -> int:
    parser = argparse.ArgumentParser(description="Use a local AI CLI to explain code-flow nodes.")
    parser.add_argument("--root", default=".")
    parser.add_argument("--flow-path", default="docs/generated/code-flow.json")
    parser.add_argument("--language", default="ko")
    parser.add_argument("--max-components", type=int, default=24)
    parser.add_argument("--ai-command", required=True)
    parser.add_argument("--timeout", type=int, default=120)
    args = parser.parse_args()

    root = Path(args.root).resolve()
    flow_path = (root / args.flow_path).resolve()
    flow = json.loads(flow_path.read_text(encoding="utf-8"))
    ranked = sorted(flow.get("components", []), key=lambda item: (-component_score(flow, item), item["name"]))
    components = ranked[: args.max_components]

    enriched = 0
    failures = []
    for component in components:
        prompt = build_prompt(flow, component, root, args.language)
        try:
            component["description"] = run_ai(args.ai_command, prompt, args.timeout)
            enriched += 1
        except Exception as error:
            failures.append(f"{component['name']}: {error}")

    flow["descriptionGeneratedAt"] = flow.get("generatedAt")
    flow["descriptionSource"] = "local-ai"
    flow_path.write_text(json.dumps(flow, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    data_js_path = flow_path.with_name("code-flow-data.js")
    data_js_path.write_text("window.CODE_FLOW_DATA = " + json.dumps(flow, ensure_ascii=False, indent=2) + ";\n", encoding="utf-8")

    print(f"AI enriched components: {enriched}")
    print(f"Flow: {flow_path}")
    if failures:
        print("Failed components:")
        for failure in failures[:10]:
            print(f"- {failure}")
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
