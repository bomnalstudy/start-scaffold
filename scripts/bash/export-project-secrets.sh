#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

RUNNER=""
RUNNER_ARGS=()
if command -v pwsh >/dev/null 2>&1; then
  RUNNER="pwsh"
  RUNNER_ARGS=(-NoProfile -File)
elif command -v powershell.exe >/dev/null 2>&1; then
  RUNNER="powershell.exe"
  RUNNER_ARGS=(-NoProfile -ExecutionPolicy Bypass -File)
else
  echo "A PowerShell runtime is required for export-project-secrets in WSL right now." >&2
  echo "This flow is still PowerShell-bridged because the secure vault bundle format is not fully native yet." >&2
  exit 1
fi

SCRIPT_PATH="${ROOT_DIR}/scripts/export-project-secrets.ps1"
if [[ "${RUNNER}" == "powershell.exe" ]]; then
  SCRIPT_PATH="$(wslpath -w "${SCRIPT_PATH}")"
fi

ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile|--source|--output|--passphrase)
      normalized="${1#--}"
      normalized="${normalized^}"
      ARGS+=("-${normalized}" "$2")
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

"${RUNNER}" "${RUNNER_ARGS[@]}" "${SCRIPT_PATH}" "${ARGS[@]}"
