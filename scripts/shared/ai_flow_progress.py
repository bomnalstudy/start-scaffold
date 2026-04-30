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


def flow_from_latest_merge(flow_path: Path, base_flow: dict, language: str, completed: int, total: int, plan_key: str) -> dict:
    merge_path = flow_path.with_name("code-flow-work") / f"merge-{completed:03}.json"
    if completed > 0 and merge_path.exists():
        try:
            partial = dict(base_flow)
            partial["flows"] = normalize_flow(read_json(merge_path))
            partial["flowSource"] = "local-ai"
            partial["flowGeneratedAt"] = datetime.now(timezone.utc).isoformat()
            partial["flowLanguage"] = language
            partial["flowComplete"] = False
            partial["flowProgress"] = progress("running", language, completed, total, plan_key, f"AI batch {completed} of {total} merged.")
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
