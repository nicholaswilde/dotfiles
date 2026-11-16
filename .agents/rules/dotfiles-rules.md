# Dotfiles Project Rules

Repository conventions for `dotfiles` (GNU Stow, SOPS, Task, Bash).

## Stow Packages

- Register every active package in `.stow-packages` (one name per line).
- Replicate target `$HOME`-relative structure under `<package>/`.
- Use `.stow-local-ignore` (Perl regexes) inside package dirs to skip non-stowed files (`\.enc$`, `^/README.*`). Create via `task create-ignore -- <package>`.
- Test with `task test` (`stow -n`) before applying `task install` or `task restow`.

## Secrets & SOPS

- **Secret & Token Env Vars (`bash/.tokens`)**: Always place secret, token, API key, and password environment variables in `bash/.tokens` (`export VAR="..."`) — never in `bash/.bash_exports`, `bash/.bashrc`, `bash/.profile`, or plaintext configs. Keep `bash/.tokens.enc` always encrypted and in sync: run `task decrypt` (if `bash/.tokens` absent), update `bash/.tokens`, then immediately run `task encrypt`.
- Never commit plaintext `.tokens` or `.env`.
- Encrypt with `task encrypt` and decrypt with `task decrypt` (never `sops -i` / `--in-place`).
- Run `task check-secrets` (`./scripts/check-secrets.sh`) before commits; install pre-commit hook via `task install-hooks`.

## Bash Configuration Standards

- **Binary Guards (All Bash Files)**: Always guard new aliases, functions, completions, hooks, and tool-specific exports in `bash/.bash_aliases`, `bash/.bash_functions`, `bash/.bash_completions`, `bash/.bash_exports`, and `bash/.bashrc` by checking the binary is installed first with `command_exists`:

  ```bash
  if command_exists direnv; then
    eval "$(direnv hook bash)"
  fi
  ```

- **Path Exports (`bash/.bash_exports`)**: Guard new `$PATH` entries with `test -d`.
- **Aliases (`bash/.bash_aliases`)**: Wrap optional commands/paths in `command_exists`, `file_exists`, `dir_exists`, or `test -d`.
- **Functions (`bash/.bash_functions`)**: Require inline `## <description>` docstring on declaration `{` line, `local` variables, and `command_exists` guards for optional tools.
- **Completions & Hooks (`bash/.bash_completions`)**: Wrap every completion/hook/eval block in `if command_exists <cmd>; then ... fi` (or file/dir check when sourcing a path).
- **Validation**: Verify edits with `bash -n <file>` and `shuck check <file>`.

## Git & Documentation

- Auto-close GitHub issues only with `Fixes #<number>` in pushed commits.
- Prefix `README.md` headings with emoji shortcodes (e.g., `## :gear: Config`).
