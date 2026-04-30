#!/usr/bin/env python3
import argparse
import json
import re
from collections import Counter, defaultdict
from datetime import datetime, timezone
from pathlib import Path


SCAN_EXTENSIONS = {
    ".cs",
    ".css",
    ".go",
    ".html",
    ".js",
    ".jsx",
    ".json",
    ".md",
    ".php",
    ".ps1",
    ".py",
    ".rs",
    ".scss",
    ".sh",
    ".sql",
    ".ts",
    ".tsx", ".vue", ".yaml", ".yml",
}

EXCLUDED_DIRS = {
    ".git", ".graveyard", ".next", ".nuxt", ".svelte-kit", ".tmp", ".turbo", ".venv",
    "__pycache__", "backups", "build", "coverage", "dist", "generated", "graphify-out",
    "node_modules", "out", "references", "start-scaffold", "target", "vendor",
}

IMPORT_PATTERNS = (
    re.compile(r"^\s*import\s+(?:.+?\s+from\s+)?['\"]([^'\"]+)['\"]", re.MULTILINE),
    re.compile(r"^\s*export\s+.+?\s+from\s+['\"]([^'\"]+)['\"]", re.MULTILINE),
    re.compile(r"require\(\s*['\"]([^'\"]+)['\"]\s*\)"),
    re.compile(r"^\s*from\s+([\w\.]+)\s+import\s+", re.MULTILINE),
    re.compile(r"^\s*import\s+([\w\.]+)", re.MULTILINE),
    re.compile(r"^\s*\.\s+['\"]?([^'\"\r\n]+\.ps1)['\"]?", re.MULTILINE),
)


def role_for(path: Path) -> str:
    text = path.as_posix().lower()
    suffix = path.suffix.lower()
    parts = set(path.parts)
    name = path.name.lower()

    if name == "skill.md" or "skills" in parts:
        return "skill"
    if suffix == ".md" or "docs" in parts:
        return "docs"
    if "test" in text or "spec" in text or "harness" in parts or "__tests__" in parts:
        return "verification"
    if "security" in text or "auth" in text or "secret" in text:
        return "security"
    if "scripts" in parts or suffix in {".ps1", ".sh"}:
        return "automation"
    if name in {"package.json", "tsconfig.json", "vite.config.ts", "next.config.js"}:
        return "config"
    if "api" in parts or "server" in parts or "backend" in parts or "routes" in parts:
        return "backend"
    if "repository" in text or "repositories" in parts:
        return "repository"
    if "service" in text or "services" in parts:
        return "service"
    if "orchestrator" in text or "workflow" in text or "pipeline" in text:
        return "orchestration"
    if "db" in parts or "database" in text or "schema" in text or suffix == ".sql":
        return "database"
    if name in {"app.js", "main.js", "index.js", "index.ts", "server.js", "preload.js"}:
        return "entrypoint"
    if suffix in {".tsx", ".jsx", ".vue", ".css", ".scss", ".html"}:
        return "ui"
    return "domain"


def should_scan(path: Path, root: Path) -> bool:
    try:
        rel = path.relative_to(root)
    except ValueError:
        return False
    if any(part in EXCLUDED_DIRS for part in rel.parts):
        return False
    if not path.is_file():
        return False
    return path.suffix.lower() in SCAN_EXTENSIONS


def component_for(path: Path) -> str:
    parts = path.parts
    if len(parts) >= 5 and parts[0] == "apps" and parts[2] == "src":
        return "/".join(parts[:4])
    if len(parts) >= 4 and parts[0] == "apps":
        return "/".join(parts[:3])
    if len(parts) >= 3 and parts[0] in {"scripts", "docs", "references", "templates"}:
        return "/".join(parts[:3])
    if len(parts) >= 2:
        return "/".join(parts[:2])
    return parts[0]


def normalize_external(target: str) -> str:
    if target.startswith("."):
        return "local module"
    return target.split("/")[0]


def extract_imports(path: Path) -> list[str]:
    try:
        content = path.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return []

    imports = []
    for pattern in IMPORT_PATTERNS:
        imports.extend(match.group(1).strip() for match in pattern.finditer(content))
    return imports


def resolve_relative_import(source: Path, target: str, known_files: set[Path]) -> Path | None:
    target_path = (source.parent / target).resolve()
    candidates = [target_path]
    candidates.extend(target_path.with_suffix(ext) for ext in SCAN_EXTENSIONS)
    candidates.extend(target_path / f"index{ext}" for ext in SCAN_EXTENSIONS)
    candidates.extend(target_path / f"__init__{ext}" for ext in {".py"})

    for candidate in candidates:
        if candidate in known_files:
            return candidate
    return None


def mermaid_id(value: str) -> str:
    cleaned = re.sub(r"[^A-Za-z0-9_]", "_", value)
    if not cleaned or cleaned[0].isdigit():
        cleaned = f"n_{cleaned}"
    return cleaned


def mermaid_label(value: str) -> str:
    return value.replace('"', "'")


def build_flow(root: Path) -> dict:
    scan_paths = [path for path in sorted(root.rglob("*")) if should_scan(path, root)]
    known_files = {path.resolve() for path in scan_paths}
    files = []
    role_counts = Counter()
    component_roles = defaultdict(Counter)
    component_files = defaultdict(list)
    component_edges = Counter()
    external_edges = Counter()
    file_components = {}

    for path in scan_paths:
        rel_path = path.relative_to(root)
        rel = rel_path.as_posix()
        role = role_for(rel_path)
        component = component_for(rel_path)
        file_components[path.resolve()] = component
        role_counts[role] += 1
        component_roles[component][role] += 1
        component_files[component].append(rel)
        files.append({"path": rel, "role": role, "component": component})

    for path in scan_paths:
        source_component = file_components[path.resolve()]
        for target in extract_imports(path):
            if target.startswith("."):
                resolved = resolve_relative_import(path.resolve(), target, known_files)
                if resolved and resolved in file_components:
                    target_component = file_components[resolved]
                    if target_component != source_component:
                        component_edges[(source_component, target_component)] += 1
            else:
                external_edges[(source_component, normalize_external(target))] += 1

    components = []
    for name, paths in sorted(component_files.items()):
        primary_role = component_roles[name].most_common(1)[0][0]
        components.append(
            {
                "name": name,
                "primaryRole": primary_role,
                "fileCount": len(paths),
                "sampleFiles": paths[:5],
            }
        )

    return {
        "generatedAt": datetime.now(timezone.utc).isoformat(),
        "root": str(root),
        "fileCount": len(files),
        "roles": dict(sorted(role_counts.items())),
        "components": components,
        "dependencies": [
            {"from": source, "to": target, "count": count}
            for (source, target), count in sorted(component_edges.items())
        ],
        "externalDependencies": [
            {"from": source, "to": target, "count": count}
            for (source, target), count in sorted(external_edges.items())
        ],
        "files": files,
    }


def render_mermaid(flow: dict, max_components: int, max_dependencies: int) -> str:
    components = sorted(flow["components"], key=lambda item: (-item["fileCount"], item["name"]))[
        :max_components
    ]
    component_names = {item["name"] for item in components}
    role_ids = {role: mermaid_id(f"role_{role}") for role in flow["roles"].keys()}
    component_ids = {item["name"]: mermaid_id(f"component_{item['name']}") for item in components}

    lines = [
        "flowchart TD",
        '  project["Current project"]',
    ]

    for role in sorted(flow["roles"].keys()):
        lines.append(f'  {role_ids[role]}["{mermaid_label(role)} ({flow["roles"][role]})"]')
        lines.append(f"  project --> {role_ids[role]}")

    for item in components:
        cid = component_ids[item["name"]]
        label = f"{item['name']}\\n{item['fileCount']} files"
        lines.append(f'  {cid}["{mermaid_label(label)}"]')
        lines.append(f"  {role_ids[item['primaryRole']]} --> {cid}")

    deps = [
        dep
        for dep in flow["dependencies"]
        if dep["from"] in component_names and dep["to"] in component_names
    ][:max_dependencies]
    for dep in deps:
        lines.append(
            f"  {component_ids[dep['from']]} -->|{dep['count']} refs| {component_ids[dep['to']]}"
        )

    lines.extend(
        [
            "  classDef role fill:#eef6ff,stroke:#2878bd,color:#102a43;",
            "  classDef component fill:#f7f7f2,stroke:#817567,color:#24211f;",
        ]
    )
    if role_ids:
        lines.append(f"  class {','.join(role_ids.values())} role;")
    if component_ids:
        lines.append(f"  class {','.join(component_ids.values())} component;")
    return "\n".join(lines) + "\n"


def ensure_generated_gitignore(root: Path, output_dir: Path) -> None:
    try:
        relative = output_dir.relative_to(root).as_posix().rstrip("/") + "/"
    except ValueError:
        return
    gitignore_path = root / ".gitignore"
    existing = gitignore_path.read_text(encoding="utf-8", errors="ignore") if gitignore_path.exists() else ""
    patterns = {line.strip() for line in existing.splitlines()}
    if relative in patterns:
        return
    prefix = "" if not existing or existing.endswith("\n") else "\n"
    gitignore_path.write_text(f"{existing}{prefix}{relative}\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Analyze a project and emit a role flow map.")
    parser.add_argument("--root", default=".")
    parser.add_argument("--output-dir", default="docs/generated")
    parser.add_argument("--emit-json", action="store_true")
    parser.add_argument("--max-components", type=int, default=24)
    parser.add_argument("--max-dependencies", type=int, default=40)
    args = parser.parse_args()

    root = Path(args.root).resolve()
    output_dir = (root / args.output_dir).resolve()
    output_dir.mkdir(parents=True, exist_ok=True)
    ensure_generated_gitignore(root, output_dir)

    flow = build_flow(root)
    json_path = output_dir / "code-flow.json"
    mermaid_path = output_dir / "code-flow.mmd"
    data_js_path = output_dir / "code-flow-data.js"
    json_path.write_text(json.dumps(flow, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    data_js = "window.CODE_FLOW_DATA = " + json.dumps(flow, ensure_ascii=False, indent=2) + ";\n"
    data_js_path.write_text(data_js, encoding="utf-8")
    mermaid_path.write_text(
        render_mermaid(flow, args.max_components, args.max_dependencies),
        encoding="utf-8",
    )

    if args.emit_json:
        print(json.dumps(flow, ensure_ascii=False, indent=2))
        return 0

    print("Code Flow Analysis")
    print(f"Root: {root}")
    print(f"Files scanned: {flow['fileCount']}")
    print(f"Mermaid: {mermaid_path}")
    print(f"JSON: {json_path}")
    print(f"Viewer data: {data_js_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
