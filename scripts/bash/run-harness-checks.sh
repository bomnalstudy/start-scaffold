#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

SCENARIO="all"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --scenario) SCENARIO="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

HARNESS_DIR="${ROOT_DIR}/harness"

assert_equal() {
  local scenario_name="$1"
  local step="$2"
  local expected="$3"
  local actual="$4"
  if [[ "${expected}" == "${actual}" ]]; then
    echo "[PASS] Scenario=${scenario_name} Step=${step}"
  else
    echo "[FAIL] Scenario=${scenario_name} Step=${step}"
    echo "  Expected: ${expected}"
    echo "  Actual:   ${actual}"
    exit 1
  fi
}

run_host_wrapper_dry_run() {
  local scenario_name="harness.host-wrapper-dry-run.v1.yaml"
  local payload_path="${ROOT_DIR}/tmp-harness-host-payload.json"
  cat > "${payload_path}" <<'EOF'
{"runId":"demo-run","stage":"plan"}
EOF

  local raw
  raw="$(python3 "${ROOT_DIR}/scripts/shared/invoke_host_wrapper.py" --host-key codex --action sync-state --payload-path "${payload_path}" --dry-run)"
  rm -f "${payload_path}"

  local success status host_key normalized_host
  success="$(printf '%s' "${raw}" | python3 -c "import sys, json; print(str(json.load(sys.stdin)['success']).lower())")"
  status="$(printf '%s' "${raw}" | python3 -c "import sys, json; print(json.load(sys.stdin)['status'])")"
  host_key="$(printf '%s' "${raw}" | python3 -c "import sys, json; print(json.load(sys.stdin)['host']['key'])")"
  normalized_host="$(printf '%s' "${raw}" | python3 -c "import sys, json; print(json.load(sys.stdin)['payload']['meta']['normalizedHost'])")"

  assert_equal "${scenario_name}" "success" "true" "${success}"
  assert_equal "${scenario_name}" "status" "dry-run" "${status}"
  assert_equal "${scenario_name}" "host.key" "codex" "${host_key}"
  assert_equal "${scenario_name}" "payload.meta.normalizedHost" "codex" "${normalized_host}"
}

run_stale_snapshot_reject() {
  local scenario_name="harness.stale-snapshot-reject.v1.yaml"
  local state_path="${ROOT_DIR}/tmp-harness-state.json"
  local patch_path="${ROOT_DIR}/tmp-harness-patch.json"
  local contract_path="${ROOT_DIR}/templates/orchestrator-state-contract.example.json"

  cat > "${state_path}" <<'EOF'
{
  "snapshotVersion": "v2",
  "artifactVersion": "v1",
  "runId": "run-20260413-150000",
  "hostTarget": "codex",
  "inputRefs": {
    "userRequest": "docs/scaffold-roadmap.md"
  },
  "stageStatus": {
    "plan": "ready",
    "execute": "pending"
  },
  "workerOutputs": {
    "prompt-orchestrator": {}
  }
}
EOF
  cp "${ROOT_DIR}/templates/orchestrator-state-patch.example.json" "${patch_path}"

  local raw
  set +e
  raw="$(python3 "${ROOT_DIR}/scripts/shared/apply_state_patch.py" --contract-path "${contract_path}" --state-path "${state_path}" --patch-path "${patch_path}" --owner prompt-orchestrator 2>/dev/null)"
  local exit_code=$?
  set -e
  rm -f "${state_path}" "${patch_path}"

  local success status error_code current_snapshot
  success="$(printf '%s' "${raw}" | python3 -c "import sys, json; print(str(json.load(sys.stdin)['success']).lower())")"
  status="$(printf '%s' "${raw}" | python3 -c "import sys, json; print(json.load(sys.stdin)['status'])")"
  error_code="$(printf '%s' "${raw}" | python3 -c "import sys, json; print(json.load(sys.stdin)['error']['code'])")"
  current_snapshot="$(printf '%s' "${raw}" | python3 -c "import sys, json; print(json.load(sys.stdin)['currentSnapshotVersion'])")"

  assert_equal "${scenario_name}" "exit-code" "1" "${exit_code}"
  assert_equal "${scenario_name}" "success" "false" "${success}"
  assert_equal "${scenario_name}" "status" "rejected-stale-snapshot" "${status}"
  assert_equal "${scenario_name}" "error.code" "stale_snapshot" "${error_code}"
  assert_equal "${scenario_name}" "currentSnapshotVersion" "v2" "${current_snapshot}"
}

case "${SCENARIO}" in
  host-wrapper-dry-run) run_host_wrapper_dry_run ;;
  stale-snapshot-reject) run_stale_snapshot_reject ;;
  all)
    run_host_wrapper_dry_run
    run_stale_snapshot_reject
    ;;
  *)
    echo "Unsupported scenario: ${SCENARIO}" >&2
    exit 1
    ;;
esac

echo "Harness checks passed."
