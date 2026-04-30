#!/usr/bin/env python3
import re
from pathlib import Path


IMPORT_RE = re.compile(r"(?:import\s+(?:.+?\s+from\s+)?|require\()\s*['\"]([^'\"]+)['\"]")
EXPORT_RE = re.compile(r"export\s+(?:async\s+)?(?:function|class|const|let|var|type|interface)\s+([A-Za-z_][\w$]*)")
JS_FUNC_RE = re.compile(r"(?:async\s+)?function\s+([A-Za-z_][\w$]*)|(?:const|let|var)\s+([A-Za-z_][\w$]*)\s*=\s*(?:async\s*)?\(")
PY_FUNC_RE = re.compile(r"^\s*(?:async\s+)?def\s+([A-Za-z_]\w*)|^\s*class\s+([A-Za-z_]\w*)", re.MULTILINE)
PS_FUNC_RE = re.compile(r"^\s*function\s+([A-Za-z_][\w-]*)", re.MULTILINE | re.IGNORECASE)
ROUTE_RE = re.compile(r"\b(?:app|router|server)\.(get|post|put|patch|delete|use)\s*\(\s*['\"]([^'\"]+)['\"]")
SQL_RE = re.compile(r"\b(SELECT|INSERT|UPDATE|DELETE|CREATE\s+TABLE|ALTER\s+TABLE)\b", re.IGNORECASE)
DB_RE = re.compile(r"\b(db|database|pool|query|transaction|sqlite|postgres|mysql)\b", re.IGNORECASE)
EVENT_RE = re.compile(r"\b(on|emit|dispatch|addEventListener|queue|schedule|cron|heartbeat|worker|job)\b", re.IGNORECASE)


def build_component_context(root: Path, components: list[dict], max_files_per_component: int, _max_chars: int) -> str:
    blocks = []
    for component in components:
        files = component.get("sampleFiles", [])
        selected_files = files if max_files_per_component <= 0 else files[:max_files_per_component]
        file_maps = [map_file(root, rel) for rel in selected_files]
        blocks.append(
            "\n".join(
                [
                    f"## {component['name']}",
                    f"role: {component.get('primaryRole')}",
                    f"fileCount: {component.get('fileCount')}",
                    "files:",
                    *[format_file_map(item) for item in file_maps if item],
                ]
            )
        )
    return "\n\n".join(blocks)


def estimate_file_map_chars(root: Path, rel_path: str) -> int:
    return len(format_file_map(map_file(root, rel_path)))


def map_file(root: Path, rel_path: str) -> dict:
    path = root / rel_path
    try:
        text = path.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return {"path": rel_path, "unreadable": True}
    suffix = path.suffix.lower()
    symbols = extract_symbols(text, suffix)
    routes = [{"method": method.upper(), "path": route} for method, route in ROUTE_RE.findall(text)[:8]]
    sql_ops = sorted({match.group(1).upper() for match in SQL_RE.finditer(text)})[:6]
    imports = IMPORT_RE.findall(text)[:10]
    return {
        "path": rel_path,
        "symbols": symbols[:12],
        "exports": EXPORT_RE.findall(text)[:8],
        "routes": routes,
        "imports": imports,
        "signals": signals(text, sql_ops),
    }


def extract_symbols(text: str, suffix: str) -> list[str]:
    if suffix == ".py":
        return [name for pair in PY_FUNC_RE.findall(text) for name in pair if name]
    if suffix == ".ps1":
        return PS_FUNC_RE.findall(text)
    matches = []
    for func_name, const_name in JS_FUNC_RE.findall(text):
        matches.append(func_name or const_name)
    return matches


def signals(text: str, sql_ops: list[str]) -> list[str]:
    found = []
    if sql_ops:
        found.append("database operations: " + ", ".join(sql_ops))
    if DB_RE.search(text):
        found.append("database access")
    if EVENT_RE.search(text):
        found.append("async/event/job flow")
    if "process.env" in text or "import.meta.env" in text:
        found.append("environment config")
    if "fetch(" in text or "axios." in text:
        found.append("external or HTTP call")
    return found[:6]


def format_file_map(item: dict) -> str:
    if item.get("unreadable"):
        return f"- {item['path']}: unreadable"
    lines = [f"- {item['path']}"]
    append_list(lines, "symbols", item.get("symbols", []))
    append_list(lines, "exports", item.get("exports", []))
    append_routes(lines, item.get("routes", []))
    append_list(lines, "imports", item.get("imports", []))
    append_list(lines, "signals", item.get("signals", []))
    return "\n".join(lines)


def append_list(lines: list[str], label: str, values: list[str]) -> None:
    if values:
        lines.append(f"  {label}: {', '.join(values)}")


def append_routes(lines: list[str], routes: list[dict]) -> None:
    if routes:
        formatted = ", ".join(f"{route['method']} {route['path']}" for route in routes)
        lines.append(f"  routes: {formatted}")
