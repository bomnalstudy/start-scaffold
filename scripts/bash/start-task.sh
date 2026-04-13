#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
. "${SCRIPT_DIR}/runtime-context.sh"

TASK_NAME=""
AGENT="codex"
PACK="start"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --task-name) TASK_NAME="$2"; shift 2 ;;
    --agent) AGENT="$2"; shift 2 ;;
    --pack) PACK="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "${TASK_NAME}" ]]; then
  echo "--task-name is required" >&2
  exit 1
fi

print_runtime_context "${AGENT}"
echo

SAFE_NAME="$(printf '%s' "${TASK_NAME}" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9 _-]+//g; s/[[:space:]]+/-/g')"
[[ -z "${SAFE_NAME}" ]] && SAFE_NAME="task"
DATE_STR="$(date +%F)"

TASKS_DIR="${ROOT_DIR}/worklogs/tasks"
WORKLOGS_DIR="${ROOT_DIR}/worklogs"
mkdir -p "${TASKS_DIR}" "${WORKLOGS_DIR}"

TASK_FILE="${TASKS_DIR}/${DATE_STR}-${SAFE_NAME}.md"
WORKLOG_FILE="${WORKLOGS_DIR}/${DATE_STR}-${SAFE_NAME}-log.md"

[[ -f "${TASK_FILE}" ]] || cp "${ROOT_DIR}/templates/orchestration-plan.md" "${TASK_FILE}"
[[ -f "${WORKLOG_FILE}" ]] || cp "${ROOT_DIR}/templates/journal-entry.md" "${WORKLOG_FILE}"

echo "Task plan file: ${TASK_FILE}"
echo "Worklog file: ${WORKLOG_FILE}"
echo

"${SCRIPT_DIR}/select-context-pack.sh" --agent "${AGENT}" --pack "${PACK}"
echo
echo "Running session-guard preflight for the task plan..."
if ! "${SCRIPT_DIR}/run-session-guard-checks.sh" --plan-path "${TASK_FILE}" --mode preflight; then
  echo
  echo "Task created, but session-guard requirements are incomplete. Fill required sections and rerun checks."
  exit 1
fi

echo
echo "Running token-ops check for the task plan..."
if ! "${SCRIPT_DIR}/run-token-ops-checks.sh" --plan-path "${TASK_FILE}"; then
  echo
  echo "Task created, but required fields are incomplete. Fill required sections and rerun checks."
  exit 1
fi

echo
echo "Task is ready. Next:"
echo "1. Fill/verify plan details in the task file."
echo "2. Fill the worklog with key changes, prevention, and next tasks."
echo "3. Run ./scripts/bash/run-orchestration.sh --pipeline all --plan-path \"${TASK_FILE}\" --worklog-path \"${WORKLOG_FILE}\""
