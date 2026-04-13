#!/usr/bin/env python3
import argparse
import json
import re
from pathlib import Path


def new_finding(rule, severity, path, message):
    return {"rule": rule, "severity": severity, "path": path, "message": message}


def get_section_body(content: str, heading: str):
    pattern = rf"(?ms)^##\s+{re.escape(heading)}\s*\r?\n(.*?)(?=^##\s+|\Z)"
    match = re.search(pattern, content)
    return match.group(1) if match else None


def meaningful_lines(body):
    if body is None:
        return []
    lines = []
    for line in re.split(r"\r?\n", body):
        t = line.strip()
        if not t or t == "-" or re.match(r"^[-*]\s*$", t) or re.match(r"^\d+\.\s*$", t):
            continue
        lines.append(t)
    return lines


def bullet_count(lines):
    return sum(1 for line in lines if re.match(r"^[-*]\s+|^\d+\.\s+", line))


def resolve(root: Path, path: str) -> Path:
    p = Path(path)
    return p if p.is_absolute() else root / p


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", required=True)
    parser.add_argument("--plan-path", default="templates/orchestration-plan.md")
    parser.add_argument("--worklog-path", default="")
    parser.add_argument("--mode", default="checkpoint", choices=["preflight", "checkpoint", "close"])
    parser.add_argument("--emit-json", action="store_true")
    args = parser.parse_args()

    root = Path(args.root).resolve()
    plan_path = resolve(root, args.plan_path)
    worklog_path = resolve(root, args.worklog_path) if args.worklog_path else None
    findings = []

    if not plan_path.exists():
        findings.append(new_finding("plan-file", "error", args.plan_path, "Plan file not found."))
    else:
        content = plan_path.read_text(encoding="utf-8")
        section_lines = {}
        for section in ["Original Goal", "MVP Scope", "Non-Goal", "Done When", "Stop If"]:
            body = get_section_body(content, section)
            lines = meaningful_lines(body)
            section_lines[section] = lines
            if body is None:
                findings.append(new_finding("required-section", "error", args.plan_path, f"Missing required section: {section}"))
            elif not lines:
                findings.append(new_finding("required-value", "error", args.plan_path, f"Section '{section}' is empty or placeholder-only."))

        if bullet_count(section_lines.get("MVP Scope", [])) > 5:
            findings.append(new_finding("mvp-too-wide", "warn", args.plan_path, "MVP Scope has more than 5 bullet items."))
        if bullet_count(section_lines.get("Done When", [])) > 5:
            findings.append(new_finding("done-when-too-wide", "warn", args.plan_path, "Done When has more than 5 bullet items."))
        if bullet_count(section_lines.get("Stop If", [])) < 2:
            findings.append(new_finding("weak-stop-condition", "warn", args.plan_path, "Stop If should list at least 2 concrete stop conditions."))

    if args.mode != "preflight":
        if not args.worklog_path:
            findings.append(new_finding("worklog-required", "error", "", "WorklogPath is required in checkpoint/close mode."))
        elif not worklog_path or not worklog_path.exists():
            findings.append(new_finding("worklog-file", "error", args.worklog_path, "Worklog file not found."))
        else:
            content = worklog_path.read_text(encoding="utf-8")
            for section in ["Mistakes / Drift Signals Observed", "Prevention for Next Session", "Direction Check", "Next Tasks"]:
                body = get_section_body(content, section)
                lines = meaningful_lines(body)
                if body is None:
                    findings.append(new_finding("required-section", "error", args.worklog_path, f"Missing required section: {section}"))
                elif not lines:
                    findings.append(new_finding("required-value", "error", args.worklog_path, f"Section '{section}' is empty or placeholder-only."))

            if args.mode == "close":
                direction = " ".join(meaningful_lines(get_section_body(content, "Direction Check"))).lower()
                if not re.search(r"stop|halt|defer|next", direction):
                    findings.append(new_finding("close-stop-rationale", "warn", args.worklog_path, "Direction Check should explain why we can stop now and what moves to next session."))

    summary = {
        "root": str(root),
        "planPath": str(plan_path),
        "worklogPath": str(worklog_path) if worklog_path else "",
        "mode": args.mode,
        "errorCount": sum(1 for f in findings if f["severity"] == "error"),
        "warnCount": sum(1 for f in findings if f["severity"] == "warn"),
        "findings": findings,
    }
    if args.emit_json:
        print(json.dumps(summary, ensure_ascii=False, indent=2))
        return 1 if summary["errorCount"] else 0

    print("Session Guard Check")
    print(f"Root: {summary['root']}")
    print(f"Plan: {summary['planPath']}")
    if summary["worklogPath"]:
        print(f"Worklog: {summary['worklogPath']}")
    print(f"Mode: {summary['mode']}")
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
