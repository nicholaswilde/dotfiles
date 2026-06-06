# Implementation Plan - Centralize Stow Package List

## Phase 1: Taskfile Refactoring
- [ ] Task: Define `STOW_PACKAGES` in `Taskfile.yaml` containing all active package directories.
- [ ] Task: Refactor loop inside the `test` task.
- [ ] Task: Refactor loop inside the `install` task.
- [ ] Task: Refactor loop inside the `restow` task.
- [ ] Task: Refactor loop inside the `delete` task.

## Phase 2: Verification
- [ ] Task: Run `task test` to verify no stow errors/conflicts occur.
- [ ] Task: Run `task test-integration` to verify clean container stowing functions correctly.
