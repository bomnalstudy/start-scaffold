#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

WORKLOG_PATH=""
EMIT_JSON="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --worklog-path) WORKLOG_PATH="$2"; shift 2 ;;
    --emit-json) EMIT_JSON="true"; shift ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "${WORKLOG_PATH}" ]]; then
  echo "--worklog-path is required" >&2
  exit 1
fi

ARGS=(--root "${ROOT_DIR}" --worklog-path "${WORKLOG_PATH}")
if [[ "${EMIT_JSON}" == "true" ]]; then
  ARGS+=(--emit-json)
fi

python3 "${ROOT_DIR}/scripts/shared/check_worklog.py" "${ARGS[@]}"
