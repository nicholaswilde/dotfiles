# dotfiles

My collection of dotfiles

## Backup

Backup the dot files before performing the installation below.

```shell
$ mv ~/.bashrc ~/.bashrc.backup
$ mv ~/.bash_aliases ~/.bash_aliases.backup
$ mv ~/.bash_exports ~/.bash_exports.backup
$ mv /.bash_functions ~/.bash_functions.backup
```

## Installation

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

## Install
```shell
$ sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/nicholaswilde/dotfiles/main/bin/install.sh)"
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/nicholaswilde/dotfiles/main/bin/install.sh) dotfiles"
```
