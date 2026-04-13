#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --contract-path|--state-path|--patch-path|--owner)
      ARGS+=("$1" "$2")
      shift 2
      ;;
    --dry-run)
      ARGS+=("$1")
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

python3 "${ROOT_DIR}/scripts/shared/apply_state_patch.py" "${ARGS[@]}"
