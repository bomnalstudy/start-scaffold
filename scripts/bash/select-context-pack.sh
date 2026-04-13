#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
. "${SCRIPT_DIR}/runtime-context.sh"

AGENT="codex"
PACK="implement"
AS_PROMPT_BLOCK="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent) AGENT="$2"; shift 2 ;;
    --pack) PACK="$2"; shift 2 ;;
    --as-prompt-block) AS_PROMPT_BLOCK="true"; shift ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

ARGS=(
  --root "${ROOT_DIR}"
  --agent "${AGENT}"
  --pack "${PACK}"
  --platform "$(runtime_platform)"
  --is-wsl "$(runtime_is_wsl)"
  --environment-pattern "$(runtime_environment_pattern)"
)

if [[ "${AS_PROMPT_BLOCK}" == "true" ]]; then
  ARGS+=(--as-prompt-block)
fi

python3 "${ROOT_DIR}/scripts/shared/select_context_pack.py" "${ARGS[@]}"
