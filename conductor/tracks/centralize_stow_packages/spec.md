# Specification - Centralize Stow Package List

## Overview
The goal of this track is to improve the maintainability of the Stow package management configuration inside `Taskfile.yaml`. Instead of maintaining multiple redundant exclusions in bash loops (`if [[ "$d" != ".git/" && ... ]]`), the active packages should be defined in a single centralized variable `STOW_PACKAGES`.

## Requirements
1. **Define variable:** Create a `STOW_PACKAGES` variable in `Taskfile.yaml` that lists all package names currently stowed (e.g. `bash`, `bat`, `cheat`, etc.).
2. **Refactor tasks:** Replace loops in `test`, `install`, `restow`, and `delete` to loop over `{{.STOW_PACKAGES}}` directly.
3. **Verify:** Ensure all tasks continue to function and the Docker integration test runs successfully without modifying target file structures.
