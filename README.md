# dotfiles

My Debian based dotfiles

## Warning

>  :warning: Warining: Installing these dotfiles using `make` will overwrite your existing dotfiles. Please backup your stuff first!

> Note: There are other `dotfiles` that are installed other than the ones listed below.

## Backup

Backup the dot files before performing the installation below.

```shell
$ mv ~/.bashrc ~/.bashrc.backup
$ mv ~/.bash_aliases ~/.bash_aliases.backup
$ mv ~/.bash_exports ~/.bash_exports.backup
$ mv /.bash_functions ~/.bash_functions.backup
```

## Installation

### Script

```shell
# Everything
$ sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/nicholaswilde/dotfiles/main/bin/install.sh)"
# Just the dot files
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/nicholaswilde/dotfiles/main/bin/install.sh) dotfiles"
```

### Manual

To keep the dot files synced with this repo, make symbolic links to the `repo` location.

```shell
$ mkdir ~/git
$ cd git
$ git clone https://github.com/nicholaswilde/dotfiles.git
$ ln -s ~/git/dotfiles/.bashrc ~/.bashrc
$ ln -s ~/git/dotfiles/.bash_aliases ~/.bash_aliases
$ ln -s ~/git/dotfiles/.bash_exports ~/.bash_exports
$ ln -s ~/git/dotfiles/.bash_functions ~/.bash_functions
# Reload
$ source ~/.bashrc
# or
$ git clone https://github.com/nicholaswilde/dotfiles.git
$ cd dotfiles
$ make
```

## Restoration

To restore the backed up dot files.

```shell
$ mv ~/.bashrc.backup ~/.bashrc
$ mv ~/.bash_aliases.backup ~/.bash_aliases
$ mv ~/.bash_exports.backup ~/.bash_exports
$ mv /.bash_functions.backup ~/.bash_functions
# Reload
$ source ~/.bashrc
```

> Note: Blank skeleton dotfiles can be found in `/etc/skel`

## Pre-commit hook

If you want to automatically generate `README.md` files with a pre-commit hook, make sure you
[install the pre-commit binary](https://pre-commit.com/#install), and add a [.pre-commit-config.yaml file](./.pre-commit-config.yaml)
to your project. Then run:

```bash
$ pre-commit install
$ pre-commit install-hooks
```

> Note: The `shellcheck` hook uses a Docker image with a `--platform linux/amd64` argument which requires [qemu-user-static](https://github.com/multiarch/qemu-user-static#getting-started) installed if running on a different architecture.

```shell
$ docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
```

## Inspiration

Inspiration for this repo has been taken from [jessfraz's](https://github.com/jessfraz/) [dotfiles](https://github.com/jessfraz/dotfiles/).

## License

[Apache 2.0 License](./LICENSE)

## Author

This project was started in 2021 by [Nicholas Wilde](https://github.com/nicholaswilde/).
