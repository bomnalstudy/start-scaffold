#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

TASK_NAME="debug-orchestrator"
KEEP_FILES="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --task-name) TASK_NAME="$2"; shift 2 ;;
    --keep-files) KEEP_FILES="true"; shift ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

ARGS=(--root "${ROOT_DIR}" --task-name "${TASK_NAME}")
if [[ "${KEEP_FILES}" == "true" ]]; then
  ARGS+=(--keep-files)
fi

python3 "${ROOT_DIR}/scripts/shared/debug_orchestrator.py" "${ARGS[@]}"
