# Implementation Plan - Centralize Stow Package List

## Phase 1: Configuration & Refactoring
- [x] Task: Create `.stow-packages` containing all active package directories (one per line). [8b5c484]
- [~] Task: Define `STOW_PACKAGES` in `Taskfile.yaml` to read from the `.stow-packages` file.
- [ ] Task: Refactor loop inside the `test` task.
- [ ] Task: Refactor loop inside the `install` task.
- [ ] Task: Refactor loop inside the `restow` task.
- [ ] Task: Refactor loop inside the `delete` task.

## Phase 2: Documentation
- [ ] Task: Update the root `README.md` to explain `.stow-packages` usage, package structure, and how to add new configs.

## Phase 3: Verification
- [ ] Task: Run `task test` to verify no stow errors/conflicts occur.
- [ ] Task: Run `task test-integration` to verify clean container stowing functions correctly.
