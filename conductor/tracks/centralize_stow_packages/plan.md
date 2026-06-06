# Implementation Plan - Centralize Stow Package List

## Phase 1: Configuration & Refactoring
- [x] Task: Create `.stow-packages` containing all active package directories (one per line). [8b5c484]
- [x] Task: Define `STOW_PACKAGES` in `Taskfile.yaml` to read from the `.stow-packages` file. [5987e2b]
- [x] Task: Refactor loop inside the `test` task. [e98e405]
- [x] Task: Refactor loop inside the `install` task. [e598568]
- [x] Task: Refactor loop inside the `restow` task. [707a666]
- [x] Task: Refactor loop inside the `delete` task. [1941aef]

## Phase 2: Documentation
- [x] Task: Update the root `README.md` to explain `.stow-packages` usage, package structure, and how to add new configs. [7620ef0]

## Phase 3: Verification
- [x] Task: Run `task test` to verify no stow errors/conflicts occur. [ae6819e]
- [~] Task: Run `task test-integration` to verify clean container stowing functions correctly.
