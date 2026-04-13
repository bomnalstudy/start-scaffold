#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
. "${SCRIPT_DIR}/runtime-context.sh"

AGENT="codex"
STAGE="start"
TASK_NAME=""
PACK="start"
PLAN_PATH=""
WORKLOG_PATH=""
PRINT_PROMPT_ONLY="false"

safe_task_name() {
  local name="$1"
  local safe
  safe="$(printf '%s' "${name}" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9 _-]+//g; s/[[:space:]]+/-/g')"
  [[ -z "${safe}" ]] && safe="task"
  printf '%s' "${safe}"
}

write_prompt_block() {
  echo
  echo "=== Skill Prompt Block (${AGENT} / ${STAGE}) ==="
  echo "Original Goal:"
  echo "MVP Scope:"
  echo "Non-Goal:"
  echo "Done When:"
  echo "Stop If:"
  echo
  echo "Plan Path: ${PLAN_PATH}"
  [[ -n "${WORKLOG_PATH}" ]] && echo "Worklog Path: ${WORKLOG_PATH}"
  echo
  echo "Request style:"
  echo "- minimum-goal MVP"
  echo "- avoid non-goal changes"
  echo "- stop when Done When is met"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent) AGENT="$2"; shift 2 ;;
    --stage) STAGE="$2"; shift 2 ;;
    --task-name) TASK_NAME="$2"; shift 2 ;;
    --pack) PACK="$2"; shift 2 ;;
    --plan-path) PLAN_PATH="$2"; shift 2 ;;
    --worklog-path) WORKLOG_PATH="$2"; shift 2 ;;
    --print-prompt-only) PRINT_PROMPT_ONLY="true"; shift ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

print_runtime_context "${AGENT}"
echo

if [[ "${STAGE}" == "start" ]]; then
  [[ -n "${TASK_NAME}" ]] || { echo "--task-name is required for --stage start" >&2; exit 1; }
  DATE_STR="$(date +%F)"
  SAFE_NAME="$(safe_task_name "${TASK_NAME}")"
  [[ -n "${PLAN_PATH}" ]] || PLAN_PATH="worklogs/tasks/${DATE_STR}-${SAFE_NAME}.md"
  [[ -n "${WORKLOG_PATH}" ]] || WORKLOG_PATH="worklogs/${DATE_STR}-${SAFE_NAME}-log.md"
  if [[ "${PRINT_PROMPT_ONLY}" != "true" ]]; then
    "${SCRIPT_DIR}/start-task.sh" --task-name "${TASK_NAME}" --agent "${AGENT}" --pack "${PACK}"
  fi
  write_prompt_block
  exit 0
fi

[[ -n "${PLAN_PATH}" && -n "${WORKLOG_PATH}" ]] || { echo "--plan-path and --worklog-path are required for ${STAGE}" >&2; exit 1; }

case "${STAGE}" in
  checkpoint)
    if [[ "${PRINT_PROMPT_ONLY}" != "true" ]]; then
      "${SCRIPT_DIR}/run-orchestration.sh" --pipeline all --plan-path "${PLAN_PATH}" --worklog-path "${WORKLOG_PATH}"
    fi
    ;;
  close)
    if [[ "${PRINT_PROMPT_ONLY}" != "true" ]]; then
      "${SCRIPT_DIR}/run-session-guard-checks.sh" --plan-path "${PLAN_PATH}" --worklog-path "${WORKLOG_PATH}" --mode close
    fi
    ;;
  *)
    echo "Unsupported stage: ${STAGE}" >&2
    exit 1
    ;;
esac

write_prompt_block
