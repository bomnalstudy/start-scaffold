#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

PROFILE=""
TARGET_PATH=""
PRINT_EXPORTS="false"

default_profile() {
  local name
  name="${PROJECT_NAME:-$(basename "${ROOT_DIR}")}"
  [[ -z "${name}" ]] && name="default"
  printf '%s' "${name}" | tr '[:upper:]' '[:lower:]'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile) PROFILE="$2"; shift 2 ;;
    --path) TARGET_PATH="$2"; shift 2 ;;
    --print-exports) PRINT_EXPORTS="true"; shift ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

[[ -n "${PROFILE}" ]] || PROFILE="$(default_profile)"
[[ -n "${TARGET_PATH}" ]] || TARGET_PATH="${ROOT_DIR}/.local/secrets/${PROFILE}.env"

if [[ ! -f "${TARGET_PATH}" ]]; then
  echo "Secrets file not found: ${TARGET_PATH} (profile: ${PROFILE})" >&2
  exit 1
fi

loaded_keys=()

while IFS= read -r raw_line || [[ -n "${raw_line}" ]]; do
  line="$(printf '%s' "${raw_line}" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
  [[ -z "${line}" || "${line}" == \#* ]] && continue
  if [[ "${line}" != *=* ]]; then
    continue
  fi
  key="${line%%=*}"
  value="${line#*=}"
  key="$(printf '%s' "${key}" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
  key="${key#$'\ufeff'}"

  if [[ "${PRINT_EXPORTS}" == "true" ]]; then
    printf "export %s=%q\n" "${key}" "${value}"
  else
    export "${key}=${value}"
    loaded_keys+=("${key}")
  fi
done < "${TARGET_PATH}"

if [[ "${PRINT_EXPORTS}" == "true" ]]; then
  exit 0
fi

echo "Loaded ${#loaded_keys[@]} variables into the current shell session."
if [[ ${#loaded_keys[@]} -gt 0 ]]; then
  printf '%s\n' "${loaded_keys[*]}"
fi
echo "Profile: ${PROFILE}"
