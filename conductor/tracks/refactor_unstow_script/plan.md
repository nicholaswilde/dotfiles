# Implementation Plan - Refactor Unstow Script

## Phase 1: Script Modification
- [ ] Task: Edit `find_stow_packages` in `unstow.sh` to add `! -name 'tests'` and `! -name '.agents'`.
- [ ] Task: Document and print recommendations inside `unstow.sh` prompting the use of `task delete` instead.

## Phase 2: Verification
- [ ] Task: Run `./unstow.sh` dry-run on host to confirm `tests` and `.agents` are excluded from the output.
