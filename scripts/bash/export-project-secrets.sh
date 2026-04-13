#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required for export-project-secrets in native-wsl-linux mode." >&2
  exit 1
fi
if ! command -v openssl >/dev/null 2>&1; then
  echo "openssl is required for export-project-secrets in native-wsl-linux mode." >&2
  exit 1
fi

ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile|--source|--output|--passphrase)
      ARGS+=("$1" "$2")
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

python3 "${ROOT_DIR}/scripts/shared/secure_bundle.py" export --root "${ROOT_DIR}" "${ARGS[@]}"
