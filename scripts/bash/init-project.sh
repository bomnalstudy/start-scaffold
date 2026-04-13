#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

LOCAL_DIR="${ROOT_DIR}/.local"
LOCAL_SECRETS_DIR="${LOCAL_DIR}/secrets"
HANDOFF_DIR="${ROOT_DIR}/handoff"
SECURE_SECRETS_DIR="${ROOT_DIR}/secure-secrets"
WORKLOG_DIR="${ROOT_DIR}/worklogs"
GRAVEYARD_DIR="${ROOT_DIR}/.graveyard"
GRAVEYARD_FILES_DIR="${GRAVEYARD_DIR}/files"
GRAVEYARD_NOTES_DIR="${GRAVEYARD_DIR}/notes"

PROJECT_NAME="${PROJECT_NAME:-$(basename "${ROOT_DIR}")}"
[[ -z "${PROJECT_NAME}" ]] && PROJECT_NAME="default"
PROFILE="$(printf '%s' "${PROJECT_NAME}" | tr '[:upper:]' '[:lower:]')"

SECRETS_PATH="${LOCAL_SECRETS_DIR}/${PROFILE}.env"
SECRETS_EXAMPLE_PATH="${ROOT_DIR}/templates/.env.local.example"
JOURNAL_EXAMPLE_PATH="${ROOT_DIR}/templates/journal-entry.md"

mkdir -p \
  "${LOCAL_DIR}" \
  "${LOCAL_SECRETS_DIR}" \
  "${HANDOFF_DIR}" \
  "${SECURE_SECRETS_DIR}" \
  "${WORKLOG_DIR}" \
  "${GRAVEYARD_FILES_DIR}" \
  "${GRAVEYARD_NOTES_DIR}"

if [[ ! -f "${SECRETS_PATH}" ]]; then
  cp "${SECRETS_EXAMPLE_PATH}" "${SECRETS_PATH}"
  echo "Created local secrets file: ${SECRETS_PATH} (profile: ${PROFILE})"
else
  echo "Local secrets file already exists: ${SECRETS_PATH} (profile: ${PROFILE})"
fi

TODAY="$(date +%F)"
INITIAL_LOG_PATH="${WORKLOG_DIR}/${TODAY}-bootstrap.md"

if [[ ! -f "${INITIAL_LOG_PATH}" ]]; then
  cp "${JOURNAL_EXAMPLE_PATH}" "${INITIAL_LOG_PATH}"
  echo "Created initial worklog: ${INITIAL_LOG_PATH}"
else
  echo "Worklog already exists: ${INITIAL_LOG_PATH}"
fi

echo
echo "Next steps:"
echo "1. Fill in .local/secrets/${PROFILE}.env"
echo "2. Run ./scripts/bash/select-context-pack.sh --agent codex --pack start"
echo "3. Run ./scripts/bash/start-task.sh --task-name \"my first mvp\" --agent codex --pack start"
echo "4. Read AGENTS.md and docs/workflow.md"
echo "5. Archive retired files with ./scripts/bash/archive-to-graveyard.sh --path <file>"
