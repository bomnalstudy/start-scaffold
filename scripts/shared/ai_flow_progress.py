import json
from datetime import datetime, timezone
from pathlib import Path

from ai_flow_normalize import normalize_flow


def read_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8-sig"))


def progress(status: str, language: str, completed: int, total: int, plan_key: str, message: str = "", error: str = "") -> dict:
    payload = {
        "status": status,
        "language": language,
        "completedBatches": completed,
        "totalBatches": total,
        "planKey": plan_key,
        "updatedAt": datetime.now(timezone.utc).isoformat(),
    }
    if message:
        payload["message"] = message
    if error:
        payload["error"] = error[:800]
    return payload


def latest_successful_merge(flow_path: Path) -> tuple[int, Path | None]:
    work_dir = flow_path.with_name("code-flow-work")
    latest_index = 0
    latest_path = None
    for path in sorted(work_dir.glob("merge-*.json")):
        try:
            index = int(path.stem.split("-")[-1])
        except ValueError:
            continue
        if index > latest_index:
            latest_index = index
            latest_path = path
    return latest_index, latest_path


def flow_from_latest_merge(flow_path: Path, base_flow: dict, language: str, completed: int, total: int, plan_key: str) -> dict:
    latest_index, merge_path = latest_successful_merge(flow_path)
    if merge_path:
        try:
            partial = dict(base_flow)
            partial["flows"] = normalize_flow(read_json(merge_path))
            partial["flowSource"] = "local-ai"
            partial["flowGeneratedAt"] = datetime.now(timezone.utc).isoformat()
            partial["flowLanguage"] = language
            partial["flowComplete"] = False
            partial["flowProgress"] = progress("running", language, completed, total, plan_key, f"Latest visible flow is from successful merge {latest_index} of {total}.")
            partial["flowProgress"]["visibleMergeBatch"] = latest_index
            return partial
        except Exception:
            pass
    return read_json(flow_path) if flow_path.exists() else dict(base_flow)


def completed_batch_count(memory: dict | None, language: str, total: int, plan_key: str) -> int:
    if not memory or memory.get("flowLanguage") != language or memory.get("flowComplete") is True:
        return 0
    flow_progress = memory.get("flowProgress", {})
    if flow_progress.get("planKey") != plan_key:
        return 0
    try:
        completed = int(flow_progress.get("completedBatches", 0))
    except (TypeError, ValueError):
        return 0
    return min(max(completed, 0), total)
