#!/usr/bin/env python3
import argparse
import json
import re
from pathlib import Path


def section(content: str, heading: str):
    match = re.search(rf"(?ms)^##\s+{re.escape(heading)}\s*\r?\n(.*?)(?=^##\s+|\Z)", content)
    return match.group(1) if match else None


def filled(body: str) -> bool:
    if body is None:
        return False
    for line in re.split(r"\r?\n", body):
        t = line.strip()
        if not t or t == "-" or re.match(r"^-+\s*$|^[-*]\s*$", t):
            continue
        return True
    return False


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", required=True)
    parser.add_argument("--plan-path", default="templates/orchestration-plan.md")
    parser.add_argument("--emit-json", action="store_true")
    args = parser.parse_args()

    root = Path(args.root).resolve()
    plan_path = Path(args.plan_path)
    if not plan_path.is_absolute():
        plan_path = root / plan_path

    findings = []
    if not plan_path.exists():
        findings.append({"rule": "plan-file", "severity": "error", "path": args.plan_path, "message": "Plan file not found."})
    else:
        content = plan_path.read_text(encoding="utf-8")
        for heading in ["Original Goal", "MVP Scope", "Non-Goal", "Done When", "Stop If"]:
            body = section(content, heading)
            if body is None:
                findings.append({"rule": "required-section", "severity": "error", "path": args.plan_path, "message": f"Missing required section: {heading}"})
            elif not filled(body):
                findings.append({"rule": "required-value", "severity": "error", "path": args.plan_path, "message": f"Section '{heading}' is empty or placeholder-only."})

    summary = {
        "root": str(root),
        "planPath": str(plan_path),
        "errorCount": sum(1 for f in findings if f["severity"] == "error"),
        "warnCount": 0,
        "findings": findings,
    }
    if args.emit_json:
        print(json.dumps(summary, ensure_ascii=False, indent=2))
        return 1 if summary["errorCount"] else 0

    print("Token Ops Check")
    print(f"Root: {summary['root']}")
    print(f"Plan: {summary['planPath']}")
    print(f"Errors: {summary['errorCount']}")
    print("Warnings: 0")
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
