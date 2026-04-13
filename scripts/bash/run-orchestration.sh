#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

PIPELINE="all"
PLAN_PATH="templates/orchestration-plan.md"
WORKLOG_PATH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --pipeline) PIPELINE="$2"; shift 2 ;;
    --plan-path) PLAN_PATH="$2"; shift 2 ;;
    --worklog-path) WORKLOG_PATH="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

stage() {
  echo
  echo "== $1 =="
}

case "${PIPELINE}" in
  session-guard)
    stage "Verify"
    if [[ -n "${WORKLOG_PATH}" ]]; then
      "${SCRIPT_DIR}/run-session-guard-checks.sh" --plan-path "${PLAN_PATH}" --worklog-path "${WORKLOG_PATH}" --mode checkpoint
    else
      "${SCRIPT_DIR}/run-session-guard-checks.sh" --plan-path "${PLAN_PATH}" --mode preflight
    fi
    ;;
  code-rules)
    stage "Verify"
    "${SCRIPT_DIR}/run-code-rules-checks.sh"
    ;;
  token-ops)
    stage "Verify"
    "${SCRIPT_DIR}/run-token-ops-checks.sh" --plan-path "${PLAN_PATH}"
    ;;
  all)
    stage "Verify Session Guard"
    if [[ -n "${WORKLOG_PATH}" ]]; then
      "${SCRIPT_DIR}/run-session-guard-checks.sh" --plan-path "${PLAN_PATH}" --worklog-path "${WORKLOG_PATH}" --mode checkpoint
    else
      "${SCRIPT_DIR}/run-session-guard-checks.sh" --plan-path "${PLAN_PATH}" --mode preflight
    fi
    stage "Verify Token Ops"
    "${SCRIPT_DIR}/run-token-ops-checks.sh" --plan-path "${PLAN_PATH}"
    stage "Verify Code Rules"
    "${SCRIPT_DIR}/run-code-rules-checks.sh"
    ;;
  *)
    echo "Unsupported pipeline: ${PIPELINE}" >&2
    exit 1
    ;;
esac
