#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

EMIT_JSON="false"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --emit-json) EMIT_JSON="true"; shift ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

ARGS=(--root "${ROOT_DIR}")
if [[ "${EMIT_JSON}" == "true" ]]; then
  ARGS+=(--emit-json)
fi

python3 "${ROOT_DIR}/scripts/shared/check_code_rules.py" "${ARGS[@]}"
