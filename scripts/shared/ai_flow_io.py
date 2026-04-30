#!/usr/bin/env python3
import json
import subprocess
import tempfile
from pathlib import Path


def decode_output(raw: bytes) -> str:
    candidates = [
        raw.decode("utf-8", errors="replace"),
        raw.decode("cp949", errors="replace"),
    ]
    return min(candidates, key=lambda text: text.count("�") + text.count("?먯") + text.count("?쒕"))


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

    stdout = decode_output(completed.stdout).strip()
    stderr = decode_output(completed.stderr).strip()
    if completed.returncode != 0:
        raise RuntimeError(stderr or f"AI command exited with {completed.returncode}")

    start = stdout.find("{")
    end = stdout.rfind("}")
    if start < 0 or end < start:
        detail = stdout or stderr or "(empty output)"
        raise RuntimeError(f"AI command did not return JSON. Output: {detail[:1200]}")
    return json.loads(stdout[start : end + 1])


def chunked(items: list[dict], size: int) -> list[list[dict]]:
    return [items[index : index + size] for index in range(0, len(items), size)]


def save_batch(work_dir: Path, index: int, data: dict) -> None:
    save_indexed(work_dir, "batch", index, data)


def save_merge(work_dir: Path, index: int, data: dict) -> None:
    save_indexed(work_dir, "merge", index, data)


def save_prompt(work_dir: Path, name: str, text: str) -> None:
    work_dir.mkdir(parents=True, exist_ok=True)
    (work_dir / name).write_text(text + "\n", encoding="utf-8")


def save_indexed(work_dir: Path, prefix: str, index: int, data: dict) -> None:
    work_dir.mkdir(parents=True, exist_ok=True)
    (work_dir / f"{prefix}-{index:03}.json").write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
