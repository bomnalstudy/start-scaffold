#!/usr/bin/env python3
import argparse
import json
import re
from pathlib import Path


def new_finding(rule, severity, path, message):
    return {"rule": rule, "severity": severity, "path": path, "message": message}


def get_section_body(content: str, heading: str):
    match = re.search(rf"(?ms)^##\s+{re.escape(heading)}\s*\r?\n(.*?)(?=^##\s+|\Z)", content)
    return match.group(1) if match else None


def section_filled(body: str) -> bool:
    if body is None:
        return False
    for line in re.split(r"\r?\n", body):
        t = line.strip()
        if not t or t == "-" or re.match(r"^\d+\.\s*$", t) or re.match(r"^[-*]\s*$", t):
            continue
        return True
    return False


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", required=True)
    parser.add_argument("--worklog-path", required=True)
    parser.add_argument("--emit-json", action="store_true")
    args = parser.parse_args()

    root = Path(args.root).resolve()
    worklog_path = Path(args.worklog_path)
    if not worklog_path.is_absolute():
        worklog_path = root / worklog_path

    findings = []
    if not worklog_path.exists():
        findings.append(new_finding("worklog-file", "error", args.worklog_path, "Worklog file not found."))
    else:
        content = worklog_path.read_text(encoding="utf-8")
        required_sections = [
            "Original Goal",
            "MVP Scope (This Session)",
            "Key Changes",
            "Validation",
            "Mistakes / Drift Signals Observed",
            "Prevention for Next Session",
            "Direction Check",
            "Next Tasks",
        ]
        for section in required_sections:
            body = get_section_body(content, section)
            if body is None:
                findings.append(new_finding("required-section", "error", args.worklog_path, f"Missing required section: {section}"))
            elif not section_filled(body):
                findings.append(new_finding("required-value", "error", args.worklog_path, f"Section '{section}' is empty or placeholder-only."))

    summary = {
        "root": str(root),
        "worklogPath": str(worklog_path),
        "errorCount": sum(1 for f in findings if f["severity"] == "error"),
        "warnCount": sum(1 for f in findings if f["severity"] == "warn"),
        "findings": findings,
    }

    if args.emit_json:
        print(json.dumps(summary, ensure_ascii=False, indent=2))
        return 1 if summary["errorCount"] else 0

    print("Worklog Check")
    print(f"Root: {summary['root']}")
    print(f"Worklog: {summary['worklogPath']}")
    print(f"Errors: {summary['errorCount']}")
    print(f"Warnings: {summary['warnCount']}")
    print()
    if not findings:
        print("No findings.")
        return 0
    for finding in findings:
        print(f"[{finding['severity'].upper()}] [{finding['rule']}] {finding['path']}")
        print(f"  {finding['message']}")
    return 1 if summary["errorCount"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
