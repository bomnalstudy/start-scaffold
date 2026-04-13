#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
HOOKS_PATH="${ROOT_DIR}/.githooks"

if [[ ! -d "${ROOT_DIR}/.git" ]]; then
  echo "Not a git repository: ${ROOT_DIR}" >&2
  exit 1
fi

git -C "${ROOT_DIR}" config core.hooksPath ".githooks"
echo "Installed git hooks path: ${HOOKS_PATH}"
echo "pre-commit and pre-push checks are now active."
