#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required for import-project-secrets in native-wsl-linux mode." >&2
  exit 1
fi
if ! command -v openssl >/dev/null 2>&1; then
  echo "openssl is required for import-project-secrets in native-wsl-linux mode." >&2
  exit 1
fi

DEFAULT_PROFILE="${PROJECT_NAME:-$(basename "${ROOT_DIR}")}"
DEFAULT_PROFILE="${DEFAULT_PROFILE,,}"

PROFILE="${DEFAULT_PROFILE}"
BUNDLE_PATH=""
OUTPUT=""
PASSPHRASE=""
ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile|--output|--passphrase)
      case "$1" in
        --profile) PROFILE="$2" ;;
        --output) OUTPUT="$2" ;;
        --passphrase) PASSPHRASE="$2" ;;
      esac
      ARGS+=("$1" "$2")
      shift 2
      ;;
    --bundle-path)
      BUNDLE_PATH="$2"
      ARGS+=("$1" "$2")
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if [[ -z "${BUNDLE_PATH}" ]]; then
  BUNDLE_PATH="${ROOT_DIR}/secure-secrets/${PROFILE}.vault.json"
fi

BUNDLE_FORMAT=""
if [[ -f "${BUNDLE_PATH}" ]]; then
  BUNDLE_FORMAT="$(python3 - "${BUNDLE_PATH}" <<'PY'
import json
import sys
from pathlib import Path
path = Path(sys.argv[1])
try:
    bundle = json.loads(path.read_text(encoding="utf-8-sig"))
    print(int(bundle.get("format", 1)))
except Exception:
    print("unknown")
PY
)"
fi

if [[ "${BUNDLE_FORMAT}" == "3" ]]; then
  python3 "${ROOT_DIR}/scripts/shared/secure_bundle.py" import --root "${ROOT_DIR}" "${ARGS[@]}"
  exit 0
fi

RUNNER=""
RUNNER_ARGS=()
if command -v pwsh >/dev/null 2>&1; then
  RUNNER="pwsh"
  RUNNER_ARGS=(-NoProfile -File)
elif command -v powershell.exe >/dev/null 2>&1; then
  RUNNER="powershell.exe"
  RUNNER_ARGS=(-NoProfile -ExecutionPolicy Bypass -File)
fi

if [[ -z "${RUNNER}" ]]; then
  echo "Legacy vault formats require a PowerShell runtime in WSL, or re-export the profile to format 3 first." >&2
  exit 1
fi

SCRIPT_PATH="${ROOT_DIR}/scripts/import-project-secrets.ps1"
if [[ "${RUNNER}" == "powershell.exe" ]]; then
  SCRIPT_PATH="$(wslpath -w "${SCRIPT_PATH}")"
  if [[ -n "${BUNDLE_PATH}" ]]; then
    BUNDLE_PATH="$(wslpath -w "${BUNDLE_PATH}")"
  fi
  if [[ -n "${OUTPUT}" ]]; then
    OUTPUT="$(wslpath -w "${OUTPUT}")"
  fi
fi

BRIDGE_ARGS=()
BRIDGE_ARGS+=("-Profile" "${PROFILE}")
if [[ -n "${BUNDLE_PATH}" ]]; then
  BRIDGE_ARGS+=("-BundlePath" "${BUNDLE_PATH}")
fi
if [[ -n "${OUTPUT}" ]]; then
  BRIDGE_ARGS+=("-Output" "${OUTPUT}")
fi
if [[ -n "${PASSPHRASE}" ]]; then
  BRIDGE_ARGS+=("-Passphrase" "${PASSPHRASE}")
fi

echo "Legacy vault detected. Falling back to PowerShell-bridged import." >&2
"${RUNNER}" "${RUNNER_ARGS[@]}" "${SCRIPT_PATH}" "${BRIDGE_ARGS[@]}"
