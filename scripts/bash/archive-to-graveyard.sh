#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

TARGET_PATH=""
REASON="Retired file"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --path) TARGET_PATH="$2"; shift 2 ;;
    --reason) REASON="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "${TARGET_PATH}" ]]; then
  echo "--path is required" >&2
  exit 1
fi

python3 "${ROOT_DIR}/scripts/shared/archive_to_graveyard.py" --root "${ROOT_DIR}" --path "${TARGET_PATH}" --reason "${REASON}"
