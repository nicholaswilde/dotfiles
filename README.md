# :package: dotfiles :floppy_disk:

[![task](https://img.shields.io/badge/task-enabled-brightgreen?logo=task&logoColor=white&style=for-the-badge)](https://taskfile.dev/#/)

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/),
[SOPS](https://getsops.io/), [Task](https://taskfile.dev/), and Bash.

---

## :rocket: TL;DR

> [!WARNING]
> `task install` and `task restow` run `stow --adopt` followed by `git restore`
> on stowed packages, reverting modified tracked files in those packages.

```shell
task bootstrap   # Decrypt secrets, stow packages, and install git hooks
task test        # Dry-run stow across all packages in .stow-packages
task install     # Stow all packages into ~/
```

---

## :gear: Config

### :key: Encryption & Secrets

Secrets and token environment variables belong in `bash/.tokens` (never in
`bash/.bash_exports`, `bash/.bashrc`, `bash/.profile`, or plaintext app configs).
Decrypt `bash/.tokens.enc` using SOPS and Task:

```shell
task decrypt
```

```shell
sops -d --input-type dotenv --output-type dotenv ./bash/.tokens.enc > ./bash/.tokens
```

After updating `bash/.tokens`, always re-encrypt `bash/.tokens.enc`:

```shell
task encrypt
```

Install the pre-commit hook and verify staged files contain no plaintext
secrets:

```shell
task install-hooks
task check-secrets
```

### :no_entry_sign: Ignore Files

- Add a `.stow-local-ignore` file (Perl regexes, e.g. `\.enc$`) to a package
  directory to skip files when stowing (`task create-ignore -- <package>`).
- Add plaintext secret paths (e.g. `.tokens`) to `.gitignore` so they are never
  committed to the repository.

### :open_file_folder: Packages Configuration

Active Stow packages are listed in [`.stow-packages`](./.stow-packages) (26
packages: `bash`, `tmux`, `ripgrep`, `bat`, `xclip`, `ssh`, `gnupg`, `nvim`,
`micro`, `gh`, `git`, `lazygit`, `lazydocker`, `cheat`, `glow`, `glamour`,
`mise`, `pvetui`, `btop`, `rtk`, `tfa`, `gopass`, `eget`, `systemd`,
`neofetch`, `rustscan`):

- Each line represents a package directory processed by GNU Stow.
- Lines starting with `#` and empty lines are ignored.
- `Taskfile.yaml` tasks (`task install`, `task restow`, `task test`,
  `task delete`) and `unstow.sh` read directly from `.stow-packages`.

To add a new package:

1. Create `<package>/` replicating the `$HOME`-relative path.
2. Add `<package>` to `.stow-packages`.
3. Dry-run with `task test`, then apply with `task install` (or
   `stow -v -t ~/ <package>`).

### :cat: Terminal Colors

The `.catppuccin_active` file acts as a flag to activate high-contrast
Catppuccin Mocha color settings for `whiptail` through `bash/.bash_exports`.

---

## :pencil: Usage

> [!WARNING]
> Using the `reload` alias may add and commit sensitive data if not excluded in
> `.stow-local-ignore` and `.gitignore`.

Common Stow and Task commands:

```shell
task bootstrap         # Decrypt secrets, stow packages, install hooks
task update            # Pull main, update assets, decrypt, restow, reload shell
task restow            # Restow all packages from .stow-packages
task test              # Dry-run stow across .stow-packages
task test-integration  # Run Debian Docker integration test (tests/run.sh)
```

Manage a single package (e.g. `bash`):

```shell
stow -v -t ~/ bash     # Stow package
stow -n -v -t ~/ bash  # Dry-run package
stow -D -v -t ~/ bash  # Unstow package
stow -R -v -t ~/ bash  # Restow package
```

Bash helper aliases and functions:

```shell
gpd      # Pull dotfiles main branch
lf       # List bash functions
aliases  # List bash aliases
```

---

## :robot: AI Agents & Skills

Repository rules and custom agent skills are defined in [`AGENTS.md`](./AGENTS.md)
and [`.agents/skills_catalog.md`](./.agents/skills_catalog.md):

- **Rules**: [`.agents/rules/dotfiles-rules.md`](./.agents/rules/dotfiles-rules.md)
  (binary `command_exists` guards in `bash/`, `.tokens` secret routing, Stow
  conventions).
- **Skills**: `add-app`, `add-path-to-env`, `app-sync`, `check-configs`,
  `check-secrets`, `manage-bash-aliases`, `manage-bash-completions`,
  `manage-bash-exports`, `manage-bash-functions`, `verify-bash-configs`.

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
