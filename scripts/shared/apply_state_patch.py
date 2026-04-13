#!/usr/bin/env python3
import argparse
import json
from datetime import datetime
from pathlib import Path


def read_json(path: str) -> dict:
    raw = Path(path).read_text(encoding="utf-8").strip()
    return json.loads(raw) if raw else {}


def write_json(path: str, value: dict):
    p = Path(path)
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(value, ensure_ascii=False, indent=2), encoding="utf-8")


def has_prefix(path: str, prefix: str) -> bool:
    return path == prefix or path.startswith(prefix + ".")


def set_nested(target: dict, dotted_path: str, value):
    cursor = target
    segments = dotted_path.split(".")
    for segment in segments[:-1]:
        if segment not in cursor or not isinstance(cursor[segment], dict):
            cursor[segment] = {}
        cursor = cursor[segment]
    cursor[segments[-1]] = value


def get_allowed_prefixes(contract: dict, owner: str):
    prefixes = []
    for shared_key, definition in contract.get("sharedValues", {}).items():
        if definition.get("owner") == owner or owner == "main-orchestrator":
            prefixes.append(shared_key)
    for namespace in contract.get("workerNamespaces", {}).get(owner, []):
        prefixes.append(namespace)
    return sorted(set(prefixes))


def field_policy(contract: dict, patch_path: str):
    top_level = patch_path.split(".")[0]
    return contract.get("sharedValues", {}).get(top_level)


def writer_allowed(policy: dict, owner: str) -> bool:
    return owner in policy.get("allowedWriters", [])


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--contract-path", required=True)
    parser.add_argument("--state-path", required=True)
    parser.add_argument("--patch-path", required=True)
    parser.add_argument("--owner", required=True)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    contract = read_json(args.contract_path)
    state = read_json(args.state_path)
    patch_document = read_json(args.patch_path)

    if "snapshotVersion" not in patch_document:
        raise ValueError("Patch must include snapshotVersion.")
    if "changes" not in patch_document:
        raise ValueError("Patch must include changes.")

    current_snapshot_version = str(state.get("snapshotVersion", ""))
    patch_snapshot_version = str(patch_document["snapshotVersion"])
    run_id = str(patch_document.get("runId", f"run-{datetime.now().strftime('%Y%m%d-%H%M%S')}"))
    changes = patch_document["changes"]
    patch_keys = list(changes.keys())

    if patch_snapshot_version != current_snapshot_version:
        result = {
            "success": False,
            "status": "rejected-stale-snapshot",
            "runId": run_id,
            "owner": args.owner,
            "snapshotVersion": patch_snapshot_version,
            "currentSnapshotVersion": current_snapshot_version,
            "patchKeys": patch_keys,
            "error": {
                "code": "stale_snapshot",
                "message": f"Patch snapshotVersion '{patch_snapshot_version}' does not match current snapshotVersion '{current_snapshot_version}'.",
            },
        }
        print(json.dumps(result, ensure_ascii=False, indent=2))
        return 1

    allowed_prefixes = get_allowed_prefixes(contract, args.owner)
    if not allowed_prefixes:
        raise ValueError(f"No allowed patch prefixes resolved for owner '{args.owner}'.")

    for patch_key in patch_keys:
        policy = field_policy(contract, patch_key)
        if policy is None:
            result = {
                "success": False,
                "status": "rejected-unknown-field-policy",
                "runId": run_id,
                "owner": args.owner,
                "patchKey": patch_key,
                "error": {
                    "code": "unknown_field_policy",
                    "message": f"Patch key '{patch_key}' does not map to a declared shared field policy.",
                },
            }
            print(json.dumps(result, ensure_ascii=False, indent=2))
            return 1
        if not policy.get("mutable", False):
            result = {
                "success": False,
                "status": "rejected-immutable-field",
                "runId": run_id,
                "owner": args.owner,
                "patchKey": patch_key,
                "error": {
                    "code": "immutable_field",
                    "message": f"Patch key '{patch_key}' targets an immutable shared field.",
                },
            }
            print(json.dumps(result, ensure_ascii=False, indent=2))
            return 1
        if not writer_allowed(policy, args.owner):
            result = {
                "success": False,
                "status": "rejected-writer-policy",
                "runId": run_id,
                "owner": args.owner,
                "patchKey": patch_key,
                "error": {
                    "code": "writer_not_allowed",
                    "message": f"Owner '{args.owner}' is not allowed to write patch key '{patch_key}'.",
                },
            }
            print(json.dumps(result, ensure_ascii=False, indent=2))
            return 1
        if not any(has_prefix(patch_key, prefix) for prefix in allowed_prefixes):
            result = {
                "success": False,
                "status": "rejected-owner-scope",
                "runId": run_id,
                "owner": args.owner,
                "patchKey": patch_key,
                "allowedPrefixes": allowed_prefixes,
                "error": {
                    "code": "owner_scope_violation",
                    "message": f"Patch key '{patch_key}' is outside the allowed prefixes for owner '{args.owner}'.",
                },
            }
            print(json.dumps(result, ensure_ascii=False, indent=2))
            return 1

    next_state = json.loads(json.dumps(state))
    for patch_key, patch_value in changes.items():
        set_nested(next_state, patch_key, patch_value)

    next_version = 1
    if current_snapshot_version.startswith("v") and current_snapshot_version[1:].isdigit():
        next_version = int(current_snapshot_version[1:]) + 1
    next_state["snapshotVersion"] = f"v{next_version}"
    next_state["lastUpdatedBy"] = args.owner
    next_state["lastRunId"] = run_id

    if args.dry_run:
        result = {
            "success": True,
            "status": "dry-run",
            "runId": run_id,
            "owner": args.owner,
            "patchKeys": patch_keys,
            "currentSnapshotVersion": current_snapshot_version,
            "nextSnapshotVersion": next_state["snapshotVersion"],
            "applied": False,
        }
        print(json.dumps(result, ensure_ascii=False, indent=2))
        return 0

    write_json(args.state_path, next_state)
    result = {
        "success": True,
        "status": "applied",
        "runId": run_id,
        "owner": args.owner,
        "patchKeys": patch_keys,
        "currentSnapshotVersion": current_snapshot_version,
        "nextSnapshotVersion": next_state["snapshotVersion"],
        "applied": True,
    }
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
