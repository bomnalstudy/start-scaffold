#!/usr/bin/env python3
import argparse
import json
from datetime import datetime, timezone
from pathlib import Path


def resolve_host_target(host_key: str) -> dict:
    normalized = host_key.strip().lower()
    mapping = {
        "codex": {"key": "codex", "family": "openai", "adapter": "skill-codex.ps1"},
        "openai": {"key": "codex", "family": "openai", "adapter": "skill-codex.ps1"},
        "claude": {"key": "claude", "family": "anthropic", "adapter": "skill-claude.ps1"},
        "anthropic": {"key": "claude", "family": "anthropic", "adapter": "skill-claude.ps1"},
        "local": {"key": "local", "family": "local", "adapter": ""},
    }
    if normalized not in mapping:
        raise ValueError(f"Unsupported host key '{host_key}'. Supported keys: codex, openai, claude, anthropic, local.")
    return mapping[normalized]


def read_payload(payload_json: str, payload_path: str) -> dict:
    if payload_json and payload_path:
        raise ValueError("Use either payload_json or payload_path, not both.")
    if payload_path:
        raw = Path(payload_path).read_text(encoding="utf-8-sig").strip()
        return json.loads(raw) if raw else {}
    if payload_json:
        return json.loads(payload_json)
    return {}


def write_debug_entry(log_path: str, entry: dict):
    if not log_path:
        return
    path = Path(log_path)
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as handle:
        handle.write(json.dumps(entry, ensure_ascii=False, separators=(",", ":")) + "\n")


def now_iso() -> str:
    return datetime.now(timezone.utc).astimezone().isoformat()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--host-key", required=True)
    parser.add_argument("--action", required=True)
    parser.add_argument("--payload-json", default="")
    parser.add_argument("--payload-path", default="")
    parser.add_argument("--run-id", default="")
    parser.add_argument("--timeout-seconds", type=int, default=30)
    parser.add_argument("--retry-count", type=int, default=0)
    parser.add_argument("--snapshot-version", default="v1")
    parser.add_argument("--artifact-version", default="v1")
    parser.add_argument("--owner", default="main-orchestrator")
    parser.add_argument("--debug-log-path", default="")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    run_id = args.run_id or f"run-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
    if args.timeout_seconds < 1:
        raise ValueError("timeout-seconds must be at least 1.")
    if args.retry_count < 0:
        raise ValueError("retry-count must be 0 or greater.")

    host_target = resolve_host_target(args.host_key)
    payload = read_payload(args.payload_json, args.payload_path)
    payload.setdefault("action", args.action)
    payload.setdefault("meta", {})
    payload["meta"]["requestedHost"] = args.host_key
    payload["meta"]["normalizedHost"] = host_target["key"]
    payload["meta"]["timeoutSeconds"] = args.timeout_seconds
    payload["meta"]["retryCount"] = args.retry_count

    if args.dry_run:
        write_debug_entry(args.debug_log_path, {
            "timestamp": now_iso(),
            "runId": run_id,
            "stage": "invoke-host",
            "owner": args.owner,
            "action": args.action,
            "host": host_target["key"],
            "status": "dry-run",
            "snapshotVersion": args.snapshot_version,
            "artifactVersion": args.artifact_version,
            "message": "Host wrapper dry run completed.",
            "patchKeys": [],
            "inputRefs": [],
            "scenarioId": "",
            "errorCode": None,
            "details": {"adapter": host_target["adapter"]},
        })
        result = {
            "success": True,
            "status": "dry-run",
            "action": args.action,
            "runId": run_id,
            "attempt": 0,
            "host": host_target,
            "payload": payload,
            "data": {"message": "Host wrapper dry run completed. This is the normalized invocation contract."},
            "error": None,
            "timestamp": now_iso(),
        }
        print(json.dumps(result, ensure_ascii=False, indent=2))
        return 0

    if not host_target["adapter"]:
        result = {
            "success": False,
            "status": "not-implemented",
            "action": args.action,
            "runId": run_id,
            "attempt": 1,
            "host": host_target,
            "payload": payload,
            "data": {},
            "error": {
                "code": "host_adapter_missing",
                "message": f"No concrete adapter is registered yet for host '{host_target['key']}'. Use --dry-run until the runtime adapter is implemented.",
            },
            "timestamp": now_iso(),
        }
        print(json.dumps(result, ensure_ascii=False, indent=2))
        return 1

    result = {
        "success": False,
        "status": "adapter-pending",
        "action": args.action,
        "runId": run_id,
        "attempt": 1,
        "host": host_target,
        "payload": payload,
        "data": {"adapterPath": host_target["adapter"]},
        "error": {
            "code": "adapter_pending",
            "message": f"Host wrapper normalization succeeded, but the runtime adapter handoff is still pending for action '{args.action}'.",
        },
        "timestamp": now_iso(),
    }
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
