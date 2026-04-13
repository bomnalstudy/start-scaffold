#!/usr/bin/env python3
import argparse
import re
import subprocess
from datetime import datetime
from pathlib import Path


def write_step(message: str):
    print()
    print(f"== {message} ==")


def test_exit_code(actual: int, expected: int, label: str):
    if actual != expected:
        raise RuntimeError(f"{label} expected exit code {expected} but got {actual}")
    print(f"[PASS] {label} (exit={actual})")


def set_section(content: str, heading: str, lines):
    replacement_body = "\n".join(lines)
    replacement = f"## {heading}\n{replacement_body}\n"
    pattern = rf"(?ms)^##\s+{re.escape(heading)}\s*\r?\n(.*?)(?=^##\s+|\Z)"
    return re.sub(pattern, replacement, content, count=1)


def run_command(args, cwd: Path) -> int:
    result = subprocess.run(args, cwd=str(cwd))
    return result.returncode


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", required=True)
    parser.add_argument("--task-name", default="debug-orchestrator")
    parser.add_argument("--keep-files", action="store_true")
    args = parser.parse_args()

    root = Path(args.root).resolve()
    date_str = datetime.now().strftime("%Y-%m-%d")
    safe_name = re.sub(r"\s+", "-", re.sub(r"[^a-z0-9\-_ ]", "", args.task_name.lower())).strip("-") or "debug-orchestrator"

    task_path = root / "worklogs" / "tasks" / f"{date_str}-{safe_name}.md"
    worklog_path = root / "worklogs" / f"{date_str}-{safe_name}-log.md"

    if task_path.exists():
        task_path.unlink()
    if worklog_path.exists():
        worklog_path.unlink()

    bash_dir = root / "scripts" / "bash"

    write_step("Case 1: start-task auto gate affects workflow")
    start_exit = run_command(
        ["bash", str(bash_dir / "start-task.sh"), "--task-name", args.task_name, "--agent", "codex", "--pack", "start"],
        root,
    )
    test_exit_code(start_exit, 1, "start-task blocks on empty plan via session-guard")

    if not task_path.exists():
        raise RuntimeError(f"Task file not generated: {task_path}")
    if not worklog_path.exists():
        raise RuntimeError(f"Worklog file not generated: {worklog_path}")
    print("[PASS] task/worklog files generated")

    write_step("Case 2: fill minimal plan -> preflight should pass")
    task_content = task_path.read_text(encoding="utf-8")
    task_content = set_section(task_content, "Original Goal", ["- Keep session focused on one minimal deliverable."])
    task_content = set_section(task_content, "MVP Scope", [
        "- Add session guard checks.",
        "- Run preflight and checkpoint validation.",
        "- Document debug method.",
    ])
    task_content = set_section(task_content, "Non-Goal", ["- No architecture rewrite."])
    task_content = set_section(task_content, "Done When", [
        "- Guard catches missing required sections.",
        "- Guard passes on filled minimal inputs.",
    ])
    task_content = set_section(task_content, "Stop If", [
        "- Scope expands beyond this task.",
        "- Validation requires unrelated files.",
    ])
    task_path.write_text(task_content, encoding="utf-8")

    preflight_exit = run_command(
        ["bash", str(bash_dir / "run-session-guard-checks.sh"), "--plan-path", str(task_path), "--mode", "preflight"],
        root,
    )
    test_exit_code(preflight_exit, 0, "session-guard preflight passes on minimal filled plan")

    write_step("Case 3: checkpoint with empty worklog should fail")
    checkpoint_fail_exit = run_command(
        ["bash", str(bash_dir / "run-session-guard-checks.sh"), "--plan-path", str(task_path), "--worklog-path", str(worklog_path), "--mode", "checkpoint"],
        root,
    )
    test_exit_code(checkpoint_fail_exit, 1, "session-guard checkpoint blocks empty worklog")

    write_step("Case 4: fill required worklog sections -> checkpoint should pass")
    worklog_content = worklog_path.read_text(encoding="utf-8")
    worklog_content = set_section(worklog_content, "Original Goal", ["- Keep objective fixed."])
    worklog_content = set_section(worklog_content, "MVP Scope (This Session)", ["- Validate guard behavior."])
    worklog_content = set_section(worklog_content, "Key Changes", ["- Added gate and verified pass/fail cases."])
    worklog_content = set_section(worklog_content, "Validation", ["- Ran session guard in preflight/checkpoint modes."])
    worklog_content = set_section(worklog_content, "Mistakes / Drift Signals Observed", ["- Empty plan/worklog immediately caused gate failure."])
    worklog_content = set_section(worklog_content, "Prevention for Next Session", ["- Fill plan before coding.", "- Fill worklog before close."])
    worklog_content = set_section(worklog_content, "Direction Check", [
        "- This still matches original goal and we can stop now.",
        "- Remaining expansion moves to next session.",
    ])
    worklog_content = set_section(worklog_content, "Next Tasks", [
        "1. Run all pipeline in real task.",
        "2. Tune warning thresholds if needed.",
    ])
    worklog_path.write_text(worklog_content, encoding="utf-8")

    checkpoint_pass_exit = run_command(
        ["bash", str(bash_dir / "run-session-guard-checks.sh"), "--plan-path", str(task_path), "--worklog-path", str(worklog_path), "--mode", "checkpoint"],
        root,
    )
    test_exit_code(checkpoint_pass_exit, 0, "session-guard checkpoint passes on filled worklog")

    write_step("Case 5: close mode validates stop rationale")
    close_exit = run_command(
        ["bash", str(bash_dir / "run-session-guard-checks.sh"), "--plan-path", str(task_path), "--worklog-path", str(worklog_path), "--mode", "close"],
        root,
    )
    test_exit_code(close_exit, 0, "session-guard close passes with stop rationale")

    write_step("Result")
    print("All orchestrator debug cases passed.")
    print(f"Task file: {task_path}")
    print(f"Worklog file: {worklog_path}")

    if not args.keep_files:
        task_path.unlink(missing_ok=True)
        worklog_path.unlink(missing_ok=True)
        print("Debug files removed. Use --keep-files to inspect retained samples.")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
