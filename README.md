# :package: dotfiles :floppy_disk:

[![task](https://img.shields.io/badge/task-enabled-brightgreen?logo=task&logoColor=white&style=for-the-badge)](https://taskfile.dev/#/)

Personal dotfiles managed with [enstow](https://github.com/nicholaswilde/enstow),
[Task](https://taskfile.dev/), and Bash.

---

## :rocket: TL;DR

```shell
task deps        # Install enstow (or check installed version)
task bootstrap   # Apply packages, decrypt secrets, and install git hooks
task test        # Dry-run enstow across all packages in .enstow.toml
task install     # Apply all packages into ~/
task doctor      # Audit symlink health, secret permissions (0600), and leaks
```

---

## :gear: Config

### :key: Encryption & Secrets

Secrets and token environment variables live in encrypted `.age` files inside
packages (e.g. `bash/.tokens.age` -> `~/.tokens`,
`pvetui/.config/pvetui/config.yml.age` -> `~/.config/pvetui/config.yml`) and
never in `bash/.bash_exports`, `bash/.bashrc`, `bash/.profile`, or plaintext
tracked configs.

`enstow` decrypts `.age` files strictly in memory using your age identity key
(`~/.config/sops/age/keys.txt` or `ENSTOW_AGE_KEY_FILE` / `SOPS_AGE_KEY_FILE`)
and writes decrypted targets directly to `$HOME` with `0600` permissions — no
plaintext secrets are ever stored inside the repository working tree.

Common secret workflows:

```shell
enstow keygen                     # Generate age key (~/.config/sops/age/keys.txt)
task edit                         # Edit bash/.tokens.age and re-deploy ~/.tokens
task edit -- pvetui/.config/pvetui/config.yml.age
task decrypt                      # Decrypt bash/.tokens.age -> ~/.tokens (0600)
task encrypt                      # Encrypt ~/.tokens -> bash/.tokens.age
task doctor                       # Audit secrets, 0600 perms, and .gitignore
```

Install the pre-commit hook (`enstow doctor --staged`) and verify staged files
contain no plaintext secrets or credential leaks:

```shell
task install-hooks
task check-secrets
```

### :no_entry_sign: Ignore Files

- Add a `.enstowignore` file (standard Git-style ignore patterns, e.g. `*.swp`,
  `README.md`, `.config/tmux/plugins/`) to a package directory to skip files
  during apply (`task create-ignore -- <package>`).
- Add plaintext secret paths (e.g. `.tokens`,
  `pvetui/.config/pvetui/config.yml`) to `.gitignore` so they are never
  committed to the repository.

### :open_file_folder: Packages Configuration

Active packages are configured in [`.enstow.toml`](./.enstow.toml) (28
packages: `bash`, `tmux`, `ripgrep`, `bat`, `xclip`, `ssh`, `gnupg`, `nvim`,
`micro`, `gh`, `git`, `lazygit`, `lazydocker`, `cheat`, `glow`, `glamour`,
`mise`, `pvetui`, `btop`, `rtk`, `tfa`, `gopass`, `eget`, `systemd`,
`neofetch`, `rustscan`, `hbctl`, `colab-cli`):

- `enstow` auto-discovers `.enstow.toml` from the repository root (`prune = true`
  and `mask_secrets = true` are enabled by default).

To add a new package:

1. Create `<package>/` replicating the `$HOME`-relative path (or use
   `enstow add <file> -p <package> [--encrypt]`).
2. Add `"<package>"` to `packages` in `.enstow.toml`.
3. Dry-run with `task test`, then apply with `task install` (or
   `enstow apply <package>`).

### :cat: Terminal Colors

The `.catppuccin_active` file acts as a flag to activate high-contrast
Catppuccin Mocha color settings for `whiptail` through `bash/.bash_exports`.

---

## :pencil: Usage

> [!NOTE]
> Migrating a host previously stowed with GNU Stow? `enstow apply` and
> `task restow:fix` (`enstow apply --backup`) automatically unfold legacy folded
> directory symlinks, prune stale links, and back up unmanaged conflicts to
> `~/.enstow-backup/<timestamp>`.

Common `enstow` and Task commands:

```shell
task bootstrap         # Apply packages + decrypt secrets, install git hooks
task update            # Pull main, update assets, restow, reload shell
task restow            # Restow all packages from .enstow.toml
task restow:fix        # Unfold links, prune stale, backup conflicts, and apply
task test              # Dry-run enstow across .enstow.toml
task status            # Show sync/conflict/drift status (-- --check for CI)
task diff              # Show unified diff (secrets masked)
task doctor            # Audit symlinks, 0600 secret permissions, and leaks
task check-secrets     # Run enstow doctor --staged against git index
task unstow            # Remove managed symlinks and decrypted secrets
task scrub             # Zeroize and remove decrypted secrets and symlinks
task test-integration  # Run Debian Docker integration test (tests/run.sh)
```

Manage a single package (e.g. `bash`):

```shell
enstow apply bash            # Apply package (idempotent for synced secrets)
enstow apply --dry-run bash  # Dry-run package
enstow unstow bash           # Unstow package
enstow restow bash           # Restow package
enstow status --check bash   # Check package status (non-zero on drift)
```

Bash helper aliases and functions:

```shell
gpd       # Pull dotfiles main branch
lf        # List bash functions
aliases   # List bash aliases
lt        # List decrypted ~/.tokens
addtoken  # Add or update token in ~/.tokens and re-encrypt bash/.tokens.age
```

---

## :robot: AI Agents & Skills

Repository rules and custom agent skills are defined in [`AGENTS.md`](./AGENTS.md)
and [`.agents/skills_catalog.md`](./.agents/skills_catalog.md):

- **Rules**: [`.agents/rules/dotfiles-rules.md`](./.agents/rules/dotfiles-rules.md)
  (binary `command_exists` guards in `bash/`, `.age` secret routing, `enstow`
  conventions).
- **Skills**: `add-app`, `add-path-to-env`, `app-sync`, `audit-eget`,
  `check-configs`, `check-secrets`, `commit-dotfiles`, `enforce-automation`,
  `manage-bash-aliases`, `manage-bash-completions`, `manage-bash-exports`,
  `manage-bash-functions`, `pull-dotfiles`, `restow`, `verify-bash-configs`.

---

## :bulb: Inspiration

Inspiration for this repository has been taken from [jessfraz/dotfiles][2].

---

## :balance_scale: License

[Apache License 2.0](./LICENSE)

---

## :pencil: Author

This project was started in 2025 by [Nicholas Wilde][1].

[1]: https://github.com/nicholaswilde/
[2]: https://github.com/jessfraz/dotfiles
