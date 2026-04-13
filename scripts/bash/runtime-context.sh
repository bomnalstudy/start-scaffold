#!/usr/bin/env bash
set -euo pipefail

runtime_platform() {
  local uname_out
  uname_out="$(uname -s | tr '[:upper:]' '[:lower:]')"
  case "$uname_out" in
    linux*) echo "linux" ;;
    darwin*) echo "macos" ;;
    msys*|mingw*|cygwin*) echo "windows" ;;
    *) echo "unknown" ;;
  esac
}

runtime_is_wsl() {
  if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
    echo "true"
  elif [[ -f /proc/version ]] && grep -qiE 'microsoft|wsl' /proc/version; then
    echo "true"
  else
    echo "false"
  fi
}

runtime_shell() {
  basename "${SHELL:-bash}"
}

runtime_environment_pattern() {
  echo "native-wsl-linux"
}

print_runtime_context() {
  local agent="${1:-unknown}"
  echo "Runtime Context"
  echo "Agent: ${agent}"
  echo "Platform: $(runtime_platform)"
  echo "WSL: $(runtime_is_wsl)"
  echo "Shell: $(runtime_shell)"
  echo "Environment Pattern: $(runtime_environment_pattern)"
}
