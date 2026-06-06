# Specification - Refactor Unstow Script

## Overview
The goal of this track is to align the `unstow.sh` helper script with the repository structure. It currently treats all directories at the root as packages (except `.git`, dotfiles, and `conductor`), which leads to bugs where it attempts to unstow files from the `tests/` and `.agents/` directories.

## Requirements
1. **Exclude folders:** Update `find_stow_packages` inside `unstow.sh` to explicitly exclude `tests` and `.agents`.
2. **Redirect warning:** Add comments/log outputs in `unstow.sh` recommending `task delete` (stow -D) as the safer, native alternative to raw `rm` unstow commands.
3. **Verify:** Ensure `unstow.sh` dry-run executes cleanly and does not print any files from the excluded folders.
