# Dotfiles Project Rules

Repository conventions for `dotfiles` (GNU Stow, SOPS, Task, Bash).

## Stow Packages

- Register every active package in `.stow-packages` (one name per line).
- Replicate target `$HOME`-relative structure under `<package>/`.
- Use `.stow-local-ignore` (Perl regexes) inside package dirs to skip non-stowed files (`\.enc$`, `^/README.*`). Create via `task create-ignore -- <package>`.
- Test with `task test` (`stow -n`) before applying `task install` or `task restow`.

## Secrets & SOPS

- Never commit plaintext `.tokens`, `.env`, `antigravity/.antigravity/settings.json`, or `antigravity-cli/.gemini/antigravity-cli/mcp_config.json`.
- Encrypt with `task encrypt` and decrypt with `task decrypt` (never `sops -i` / `--in-place`).
- Run `task check-secrets` (`./scripts/check-secrets.sh`) before commits; install pre-commit hook via `task install-hooks`.

## Bash Configuration Standards

- **Path Exports (`bash/.bash_exports`)**: Guard new `$PATH` entries with `test -d`.
- **Aliases (`bash/.bash_aliases`)**: Wrap optional commands/paths in `command_exists`, `file_exists`, `dir_exists`, or `test -d`.
- **Functions (`bash/.bash_functions`)**: Require inline `## <description>` docstring on declaration `{` line, `local` variables, and `command_exists` guards for optional tools.
- **Validation**: Verify edits with `bash -n <file>` and `shuck <file>`.

## Git & Documentation

- Auto-close GitHub issues only with `Fixes #<number>` in pushed commits.
- Prefix `README.md` headings with emoji shortcodes (e.g., `## :gear: Config`).
