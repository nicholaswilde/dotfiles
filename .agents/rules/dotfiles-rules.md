# Dotfiles Project Rules

Repository conventions for `dotfiles` (`enstow`, Task, Bash).

## enstow Packages

- Register every active package in `.enstow.toml` (`packages = [...]`; auto-discovered by `enstow` from repo root).
- Replicate target `$HOME`-relative structure under `<package>/` (or ingest with `enstow add <file> -p <package> [--encrypt]`).
- Use `.enstowignore` (Git-style ignore syntax, NOT Perl regexes) inside package dirs to skip non-deployed files (`README.md`, `*.swp`, `.config/tmux/plugins/`). Create via `task create-ignore -- <package>`.
- Test with `task test` (`enstow apply --dry-run --force`) before applying `task install`, `task restow`, or `task restow:fix` (`enstow apply --backup`).

## Secrets & Age Encryption (`enstow`)

- **Secret & Token Env Vars (`bash/.tokens.age`)**: Place secret, token, API key, and password env vars in `bash/.tokens.age` (`export VAR="..."`, deployed to `~/.tokens` with `0600` perms) — never in `bash/.bash_exports`, `bash/.bashrc`, `bash/.profile`, or plaintext tracked configs. Edit securely via `task edit` (`enstow edit --apply bash/.tokens.age`) or update `~/.tokens` and run `task encrypt`.
- Never store or commit plaintext `.tokens`, `pvetui/.config/pvetui/config.yml`, or `.env` inside repository working tree.
- Encrypt with `task encrypt` (`enstow encrypt`), decrypt with `task decrypt` (`enstow decrypt`) or `enstow apply`, generate keys with `enstow keygen`.
- Run `task check-secrets` (`enstow doctor --staged -s .`) and `task doctor` (`enstow doctor`) before commits; install pre-commit hook via `task install-hooks`.

## Bash Configuration Standards

- **Binary Guards (All Bash Files)**: Guard new aliases, functions, completions, hooks, and tool-specific exports in `bash/.bash_aliases`, `bash/.bash_functions`, `bash/.bash_completions`, `bash/.bash_exports`, and `bash/.bashrc` by checking binary exists first with `command_exists`:

  ```bash
  if command_exists direnv; then
    eval "$(direnv hook bash)"
  fi
  ```

- **Path Exports (`bash/.bash_exports`)**: Guard new `$PATH` entries with `test -d`.
- **Aliases (`bash/.bash_aliases`)**: Wrap optional commands/paths in `command_exists`, `file_exists`, `dir_exists`, or `test -d`.
- **Functions (`bash/.bash_functions`)**: Require inline `## <description>` docstring on declaration `{` line, `local` variables, and `command_exists` guards for optional tools.
- **Completions & Hooks (`bash/.bash_completions`)**: Wrap every completion/hook/eval block in `if command_exists <cmd>; then ... fi` (or file/dir check when sourcing path).
- **Validation**: Verify edits with `bash -n <file>` and `shuck check <file>`.

## Git & Documentation

- Auto-close GitHub issues only with `Fixes #<number>` in pushed commits.
- Prefix `README.md` headings with emoji shortcodes (e.g., `## :gear: Config`).
