# Product Guidelines

## Prose Style and Tone

- **Voice:** Clear, informative, and technical.
- **Clarity:** Code comments, commit messages, and documentation must be precise, concise, and easy to understand.
- **Structure:** Use structured markdown lists and headings. When describing bash functions, include the docstring after the opening curly brace (as specified in `AGENTS.md`).

## Visual Identity

- **Theme Consistency:** Use the Catppuccin Mocha theme where appropriate (e.g. tmux, micro, and shell colors).
- **Color Scheme:** Support high-contrast, dark-mode themes for shell interfaces (e.g. `whiptail` using `.catppuccin_active`).

## Content Formatting

- **Stow Package Structure:** Every stow package must replicate the path structure expected in the user's home directory.
- **Ignore Files:**
  - Placed inside individual packages for stow ignores (e.g., `bash/.stow-local-ignore`).
  - Plaintext secret filenames must be explicitly ignored in the root `.gitignore` and in the package's `.stow-local-ignore`.
- **Git Commit Messages:** Commit messages must follow the conventional commit format (e.g., `feat(bash): add new alias`, `chore(conductor): mark track as complete`).
- **Bash Functions:** When adding a new function to `bash/.bash_functions`, add a docstring starting with `##` on the same line as the function declaration.

## Technical Standards

- **GNU Stow Syntax:** Use standard GNU Stow flags (e.g., `-v --adopt -t ~/`) to manage symlinks.
- **Secrets Management:** plaintext secrets must never be committed to Git. Always encrypt with SOPS to `.enc` files and decrypt before stowing.
- **Task Runner:** Always define standard operations (bootstrap, install, update, encrypt, decrypt, test) in `Taskfile.yaml`.
