#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

PLAN_PATH="templates/orchestration-plan.md"
EMIT_JSON="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --plan-path) PLAN_PATH="$2"; shift 2 ;;
    --emit-json) EMIT_JSON="true"; shift ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

ARGS=(--root "${ROOT_DIR}" --plan-path "${PLAN_PATH}")
if [[ "${EMIT_JSON}" == "true" ]]; then
  ARGS+=(--emit-json)
fi

python3 "${ROOT_DIR}/scripts/shared/check_token_ops.py" "${ARGS[@]}"
