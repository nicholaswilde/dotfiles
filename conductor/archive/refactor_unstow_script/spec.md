# Specification - Refactor Unstow Script

## Overview
The goal of this track is to align the `unstow.sh` helper script with the repository structure. Instead of using `find` to dynamically identify directories (which catches non-stow directories like `tests/` and `.agents/`), the script should read package names from the centralized `.stow-packages` configuration file.

## Requirements
1. **Load config file:** Update `find_stow_packages` inside `unstow.sh` to read packages from the `.stow-packages` file (excluding comments/empty lines).
2. **Redirect warning:** Add comments/log outputs in `unstow.sh` recommending `task delete` (stow -D) as the safer, native alternative to raw `rm` unstow commands.
3. **Verify:** Ensure `unstow.sh` dry-run executes cleanly and does not print any files from the excluded folders.
