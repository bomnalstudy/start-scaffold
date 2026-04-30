#!/usr/bin/env python3
import argparse
import json
import re
from pathlib import Path


SOURCE_EXTENSIONS = {".js", ".jsx", ".ts", ".tsx", ".css", ".scss", ".less", ".html", ".json", ".md", ".ps1", ".py"}
EXCLUDED_DIRS = {".graveyard", ".local", "generated", "handoff", "node_modules", "dist", "build"}
TEMP_ALLOWLIST = {"scripts/debug-orchestrator.ps1"}
MAX_LINE_ALLOWLIST = {"package-lock.json"}
CSS_ALLOWLIST = {"apps/code-flow-board/src/styles.css"}
GRAVEYARD_ALLOWLIST = {
    "scripts/archive-to-graveyard.ps1",
    "scripts/find-code-refactor-candidates.ps1",
    "scripts/find-file-refactor-candidates.ps1",
    "scripts/run-code-rules-checks.ps1",
    "scripts/bash/run-code-rules-checks.sh",
    "scripts/shared/check_code_rules.py",
}


def finding(rule, severity, path, message):
    return {"rule": rule, "severity": severity, "path": path, "message": message}


def placeholder_worklog(text: str) -> bool:
    normalized = text.replace("\r\n", "\n")
    patterns = [
        r"(?m)^## Date\s*\n\s*YYYY-MM-DD\s*$",
        r"(?m)^## Original Goal\s*\n\s*-\s*$",
        r"(?m)^## Project / Task\s*\n\s*-\s*$",
        r"(?m)^## MVP Scope\s*\n\s*-\s*$",
        r"(?m)^## Done When\s*\n\s*-\s*$",
    ]
    count = sum(1 for pattern in patterns if re.search(pattern, normalized))
    return count >= 3


def security_findings(path: str, ext: str, content: str):
    out = []
    if ext in {".js", ".jsx", ".ts", ".tsx"}:
        has_sensitive_terms = bool(re.search(r"(?i)token|secret|password|authorization|api[_-]?key|client[_-]?secret", content))
        has_browser_storage = bool(re.search(r"(?i)localStorage\.(setItem|getItem)|sessionStorage\.(setItem|getItem)", content))
        if has_sensitive_terms and has_browser_storage:
            out.append(finding("browser-token-storage", "warn", path, "Browser token storage signal detected. Prefer safer session handling."))
        if re.search(r"dangerouslySetInnerHTML|innerHTML\s*=", content):
            out.append(finding("unsafe-html-sink", "warn", path, "Unsafe HTML sink detected. Validate or sanitize before use."))
        for line in content.splitlines():
            if re.search(r"(?i)console\.(log|debug|info|warn|error)\(|logger\.(debug|info|warn|error)\(", line) and re.search(r"(?i)(token|secret|password|authorization|api[_-]?key|client[_-]?secret)[A-Za-z0-9._\-\]\[]*", line):
                out.append(finding("sensitive-log-signal", "warn", path, "Possible sensitive log signal detected. Review redaction and logging scope."))
                break
        if re.search(r"(?i)invalid user|account disabled|user does not exist|email not found|wrong password", content) and re.search(r"(?i)login|sign in|signin|authenticate|password reset|recovery", content):
            out.append(finding("auth-enumeration-message", "warn", path, "Authentication flow appears to contain account-enumerating error text. Prefer generic auth failure responses."))
        if re.search(r"(?im)^\s*(eval\s*\(|new\s+Function\s*\()", content):
            out.append(finding("dynamic-execution", "warn", path, "Dynamic execution signal detected. Avoid eval-like patterns."))
        if re.search(r"(?i)child_process\.(exec|execSync)\(|spawn\s*\(.*shell\s*:\s*true", content):
            out.append(finding("shell-risk", "warn", path, "Shell execution risk signal detected. Prefer safer process invocation patterns."))
    if ext == ".ps1":
        for line in content.splitlines():
            if re.search(r"(?i)Write-Host|Write-Output", line) and re.search(r"(?i)\$[{(]?[A-Za-z0-9_]*(token|secret|password|authorization|api[_-]?key|client[_-]?secret)[A-Za-z0-9_]*", line):
                if not re.search(r"(?i)(Path|Dir|File|Profile)", line):
                    out.append(finding("sensitive-log-signal", "warn", path, "Possible sensitive log signal detected. Review redaction and logging scope."))
                    break
        if re.search(r"(?im)^\s*Invoke-Expression\b", content):
            out.append(finding("dynamic-execution", "warn", path, "Invoke-Expression detected. Prefer explicit commands and arguments."))
    return out


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", required=True)
    parser.add_argument("--max-lines", type=int, default=500)
    parser.add_argument("--emit-json", action="store_true")
    args = parser.parse_args()

    root = Path(args.root).resolve()
    findings = []
    files = []
    for file in root.rglob("*"):
        if not file.is_file() or file.suffix.lower() not in SOURCE_EXTENSIONS:
            continue
        rel = file.relative_to(root).as_posix()
        if any(part in EXCLUDED_DIRS for part in Path(rel).parts):
            continue
        files.append((file, rel))

    for file, rel in files:
        content = file.read_text(encoding="utf-8", errors="ignore")
        line_count = len(content.splitlines())
        ext = file.suffix.lower()

        if rel in MAX_LINE_ALLOWLIST:
            pass
        elif line_count > args.max_lines:
            findings.append(finding("max-lines", "error", rel, f"File has {line_count} lines. Limit is {args.max_lines}."))
        elif line_count > 300:
            findings.append(finding("line-budget-watch", "warn", rel, f"File has {line_count} lines. Watch for mixed responsibilities or rapid growth before it reaches {args.max_lines}."))

        if re.search(r"(^|/)(tmp|temp|scratch|playground|debug)(/|$)|(^|/)(tmp-|temp-|scratch-|playground-|debug-)|\.(tmp|bak|orig|rej)$", rel) and rel not in TEMP_ALLOWLIST:
            findings.append(finding("temporary-file", "warn", rel, "Suspicious temporary/debug file name detected. Clean it up or archive it before closing the task."))

        if rel.startswith("worklogs/") and rel.endswith(".md") and placeholder_worklog(content):
            findings.append(finding("placeholder-worklog", "error", rel, "Worklog/task file still looks like an untouched template. Fill it in or remove it."))

        if ext in {".jsx", ".tsx", ".js", ".ts"}:
            if re.search(r"style\s*=\s*\{\{", content) and "style={canvas.canvasVars}" not in content:
                findings.append(finding("inline-style", "error", rel, "Inline style object detected. Move styles to a colocated CSS file."))
            if re.search(r"@import\s+[\"'][^\"']+\.css[\"']", content):
                findings.append(finding("css-import-style", "warn", rel, "Global CSS import found in source file. Confirm this belongs in a top-level entry file."))
            has_jsx = ext in {".jsx", ".tsx"} and bool(re.search(r"<[A-Z][A-Za-z0-9]*|<div\b|<section\b", content))
            has_fetch = bool(re.search(r"\bfetch\(|\baxios\.|\buseQuery\(", content))
            has_state = bool(re.search(r"\buseReducer\(|\bcreateContext\(|\buseState\(", content))
            if has_jsx and has_fetch:
                findings.append(finding("ui-data-mix", "warn", rel, "UI rendering and data-fetching logic appear mixed in one file. Consider splitting view and data concerns."))
            if has_jsx and has_state and line_count > 200:
                findings.append(finding("ui-state-mix", "warn", rel, "Large UI file appears to mix rendering and state orchestration. Consider splitting into view and hook/state files."))
            findings.extend(security_findings(rel, ext, content))

        if re.search(r"(^|/)utils(/)?index\.(ts|tsx|js|jsx)$", rel):
            export_count = len(re.findall(r"export\s+", content))
            if export_count > 15:
                findings.append(finding("large-utils-index", "warn", rel, f"Utils barrel exports {export_count} items. This can become a catch-all entrypoint."))

        if ext == ".ps1":
            function_count = len(re.findall(r"(^|\n)\s*function\s+[A-Za-z0-9_-]+", content, re.I))
            has_param = bool(re.search(r"(?s)\[CmdletBinding\(\)\].*?param\(", content))
            if function_count >= 8 and line_count > 220:
                findings.append(finding("large-powershell-script", "warn", rel, "Large PowerShell script with many functions detected. Consider splitting helpers from the entry script."))
            if has_param and function_count >= 6 and "Write-Host" in content and line_count > 180:
                findings.append(finding("script-flow-mix", "warn", rel, "Script appears to mix entrypoint flow, reporting, and helper logic in one file. Consider separating reusable logic."))
            findings.extend(security_findings(rel, ext, content))

        if re.search(r"orchestrator|harness", rel):
            has_config = bool(re.search(r"config|PlanPath|WorklogPath", content))
            has_dispatch = bool(re.search(r"Invoke-|switch\s*\(", content))
            has_reporting = bool(re.search(r"Write-Host|Write-Step", content))
            if has_config and has_dispatch and has_reporting and line_count > 180:
                findings.append(finding("orchestrator-responsibility-mix", "warn", rel, "Orchestrator-related file appears to mix config, dispatch, and reporting concerns. Consider splitting the responsibilities."))

        if ext in {".jsx", ".tsx", ".js", ".ts", ".ps1", ".py"} and rel not in GRAVEYARD_ALLOWLIST and re.search(r"\.graveyard[\\/]", content):
            findings.append(finding("graveyard-reference", "error", rel, "Active file appears to reference .graveyard content."))

        if ext == ".css" and not rel.endswith(".module.css") and rel not in CSS_ALLOWLIST:
            findings.append(finding("css-module-preferred", "warn", rel, "Plain .css file found. Prefer colocated CSS Modules unless this is intentional global style."))

    summary = {
        "root": str(root),
        "scannedFiles": len(files),
        "errorCount": sum(1 for f in findings if f["severity"] == "error"),
        "warnCount": sum(1 for f in findings if f["severity"] == "warn"),
        "findings": findings,
    }
    if args.emit_json:
        print(json.dumps(summary, ensure_ascii=False, indent=2))
        return 1 if summary["errorCount"] else 0

    print("Code Rules Check")
    print(f"Root: {summary['root']}")
    print(f"Scanned Files: {summary['scannedFiles']}")
    print(f"Errors: {summary['errorCount']}")
    print(f"Warnings: {summary['warnCount']}")
    print()
    if not findings:
        print("No findings.")
        return 0
    for item in findings:
        print(f"[{item['severity'].upper()}] [{item['rule']}] {item['path']}")
        print(f"  {item['message']}")
    return 1 if summary["errorCount"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
