# Bash Entrypoints

This folder is reserved for Linux or WSL-friendly shell entrypoints if the scaffold adopts the `native-wsl-linux` pattern.

Current repository status:

- core Linux-native entrypoints now exist for context selection, code rules, token/session checks, orchestration, task start, and minimum-goal flow
- full parity with every PowerShell script is not complete yet
- keep new bash wrappers thin and align them with the same shared contracts used by PowerShell

Do not duplicate large orchestration logic here unless the project has explicitly chosen the Linux-first runtime pattern.
