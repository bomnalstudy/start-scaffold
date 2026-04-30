#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

OUTPUT_DIR="docs/generated"
EMIT_JSON="false"
MAX_COMPONENTS="24"
MAX_DEPENDENCIES="40"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output-dir) OUTPUT_DIR="$2"; shift 2 ;;
    --emit-json) EMIT_JSON="true"; shift ;;
    --max-components) MAX_COMPONENTS="$2"; shift 2 ;;
    --max-dependencies) MAX_DEPENDENCIES="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

ARGS=(
  --root "${ROOT_DIR}"
  --output-dir "${OUTPUT_DIR}"
  --max-components "${MAX_COMPONENTS}"
  --max-dependencies "${MAX_DEPENDENCIES}"
)

if [[ "${EMIT_JSON}" == "true" ]]; then
  ARGS+=(--emit-json)
fi

python3 "${ROOT_DIR}/scripts/shared/analyze_code_flow.py" "${ARGS[@]}"
