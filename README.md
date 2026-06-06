# :package: dotfiles :floppy_disk:
[![task](https://img.shields.io/badge/task-enabled-brightgreen?logo=task&logoColor=white&style=for-the-badge)](https://taskfile.dev/#/)

A dotfiles repo using stow.

---

## :rocket: TL;DR

> [!WARNING]
> The following command will restore any modified files in the stow packages!

```shell
task install
```

---

## :gear: Config

### :key: Encryption

Unencrypt the `.tokens` file using [SOPS](https://getsops.io/) and [Task](https://taskfile.dev/).

```
task decrypt
```

```shell
sops -d --input-type dotenv --output-type dotenv ./bash/.tokens.enc > ./bash/.tokens
```

### Ignore Files

To ignore files that stow processes (e.g. `.tokens.enc`), add a `.stow-local-ignore` file to the package directory.

To ignore files that are commited to the dotfiles repo (e.g. `.tokens`), add to `.gitignore`.

### Packages Configuration

The list of active Stow packages is centralized in the `.stow-packages` file at the root of the repository:

- Each line represents a package directory that will be processed by GNU Stow.
- Lines starting with `#` and empty lines are ignored as comments.
- Both `Taskfile.yaml` tasks (e.g., `task install`, `task test`, `task restow`, `task delete`) and helper scripts dynamically read from `.stow-packages` to determine the scope of operations.

To add a new package:
1. Create your package folder at the root (e.g. `my_new_app/`).
2. Add its folder name to the `.stow-packages` registry file on a new line.
3. Run `task install` to create the symlinks in your home directory.

### :cat: Terminal Colors

The `.catppuccin_active` file acts as a flag to activate Catppuccin color settings for `whiptail` through `.bash_exports`. If this file exists, `whiptail` will use a high-contrast Catppuccin Mocha color scheme for better readability.


---

## :pencil: Usage

> [!WARNING]
> Using the `reload` alias may add and commit sensative data if not specified in a `.stow-local-ignore` file!

Stow the `bash` package

```shell
stow -v -t ~/ bash
```

Stow the `bash` package as a test

```shell
stow -n -v -t ~/ bash
```

Unstow the `bash` package

```shell
stow -D -v -t ~/ bash
```

Restow the `bash` package

```shell
stow -R -v -t ~/ bash
```

Update local files

```shell
gpd
```

List functions

```shell
lf
```

List aliases

```shell
aliases
```

---

## :bulb: Inspiration

Inspiration for this repository has been taken from [jessfraz/dotfiles][2].

---

## :balance_scale: License

​[Apache License 2.0](./LICENSE)

---

## :pencil: Author

​This project was started in 2025 by [Nicholas Wilde][1].

[1]: https://github.com/nicholaswilde/
[2]: https://github.com/jessfraz/dotfiles
