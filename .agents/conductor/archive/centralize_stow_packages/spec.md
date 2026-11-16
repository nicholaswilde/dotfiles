# Specification - Centralize Stow Package List

## Overview
The goal of this track is to improve the maintainability of the Stow package management configuration. Instead of maintaining multiple redundant exclusions in bash loops inside `Taskfile.yaml`, the active packages should be defined in a single centralized `.stow-packages` configuration file.

## Requirements
1. **Create config file:** Create a `.stow-packages` file at the root of the repository listing all active Stow package names (one per line, with support for comments starting with `#`).
2. **Taskfile Integration:** Update `Taskfile.yaml` to read the packages list from `.stow-packages` (e.g. using `grep -v '^#' .stow-packages | xargs`) into a `STOW_PACKAGES` variable.
3. **Refactor tasks:** Replace loops in `test`, `install`, `restow`, and `delete` to loop over `{{.STOW_PACKAGES}}` directly.
4. **Documentation:** Update the root `README.md` to document the purpose of `.stow-packages` and explain how to add new packages.
5. **Verify:** Ensure all tasks continue to function and the Docker integration test runs successfully.
