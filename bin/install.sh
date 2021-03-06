#!/bin/bash
set -e
set -o pipefail

export DEBIAN_FRONTEND=noninteractive

# Get the directory the script is in.
# https://stackoverflow.com/a/246128/1061279
readonly CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Check if directory exists
function dir_exists(){
  [ -d "${1}" ]
}

# Choose a user account to use for this installation
function get_user() {
  if [[ -z "${TARGET_USER-}" ]]; then
    mapfile -t options < <(find /home/* -maxdepth 0 -printf "%f\\n" -type d)
    # if there is only one option just use that user
    if [ "${#options[@]}" -eq "1" ]; then
      readonly TARGET_USER="${options[0]}"
      printf "Using user account: %s\n" "${TARGET_USER}"
      HOME="/home/${TARGET_USER}"
      return
    fi

    # iterate through the user options and print them
    PS3='command -v user account should be used? '

    select opt in "${options[@]}"; do
      readonly TARGET_USER=$opt
      break
    done
  fi
}

function check_is_sudo() {
  if [ "$EUID" -ne 0 ]; then
    printf "Please run as root.\n"
    exit 1
  fi
}

# printf usage_error if something isn't right.
function usage_error() {
  show_usage
  exit 1
}

function show_usage() {
  echo -e "install.sh\\n\\tThis script installs my basic setup for a debian computer\\n"
  echo "Usage:"
  echo "  basemin                             - setup sources & install base pkgs"
  echo "  brew                                - get brew"
  echo "  dotfiles                            - get dotfiles"
  echo "  rust                                - get rust"
  echo "  go                                  - get go"
  echo "  pass                                - get pass"
  echo "  scripts                             - get scripts"
}

function base_min() {
	printf "\nInstalling basemin ...\n\n"
  apt update || true
  apt -y upgrade
	apt -y dist-upgrade

  apt install -y \
    adduser \
    automake \
    bash-completion \
    bc \
    build-essential \
    bzip2 \
    ca-certificates \
    coreutils \
    curl \
    dnsutils \
    file \
    findutils \
    gcc \
    git \
    gnupg \
    gnupg2 \
    grep \
    gzip \
    hostname \
    indent \
    iptables \
    jq \
    less \
    libarchive-tools \
    libc6-dev \
    locales \
    lsof \
    make \
    mount \
    nano \
    net-tools \
    policykit-1 \
    python-is-python3 \
    python3-pip \
    silversearcher-ag \
    ssh \
    strace \
    sudo \
    tar \
    tree \
    tzdata \
    unzip \
    wget \
    xz-utils \
    zip \
    --no-install-recommends

  apt autoremove -y
  apt autoclean -y
  apt clean -y
}

# install/update golang from source
function install_golang() {
  export GO_VERSION
  GO_VERSION=$(curl -sSL "https://golang.org/VERSION?m=text")
  export GO_SRC=/usr/local/go

  # if we are passing the version
  if [[ -n "$1" ]]; then
    GO_VERSION=$1
  fi

  # purge old src
  if [[ -d "$GO_SRC" ]]; then
    sudo rm -rf "$GO_SRC"
    sudo rm -rf "$GOPATH"
  fi

  GO_VERSION=${GO_VERSION#go}

  # subshell
  (
  kernel=$(uname -s | tr '[:upper:]' '[:lower:]')
  curl -sSL "https://storage.googleapis.com/golang/go${GO_VERSION}.${kernel}-amd64.tar.gz" | sudo tar -v -C /usr/local -xz
  local user="$USER"
  # rebuild stdlib for faster builds
  sudo chown -R "${user}" /usr/local/go/pkg
  CGO_ENABLED=0 /usr/local/go/bin/go install -a -installsuffix cgo std
  )
  export PATH="${PATH}:/usr/local/bin/"
}

function install_rust() {
  printf "\nInstalling rust ...\n\n"
sudo -u "${TARGET_USER}" bash <<"EOF5"
  curl https://sh.rustup.rs -sSf | sh

  # Install rust-src for rust analyzer
  rustup component add rust-src
  # Install rust-analyzer
  curl -sSL "https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-linux" -o "${HOME}/.cargo/bin/rust-analyzer"
  chmod +x "${HOME}/.cargo/bin/rust-analyzer"
  source "${HOME}/.cargo/env"
  # Install clippy
  rustup component add clippy
EOF5
}

function install_pip(){
  printf "\nInstalling pip packages ...\n\n"
sudo -u "${TARGET_USER}" bash <<"EOF2"
  pip install \
    pre-commit
EOF2
}

function install_ruby() {
  printf "\nInstalling pip packages ...\n\n"
  apt-get install -y \
    rbenv \
    libssl-dev
sudo -u "${TARGET_USER}" bash <<"EOF4"
  git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
  rbenv install 2.3.6
  rbenv global 2.3.6
EOF4
}

function install_brew() {
  printf "\nInstalling brew ...\n\n"
sudo -u "${TARGET_USER}" bash <<"EOF3"
  git clone https://github.com/Homebrew/brew "${HOME}/.linuxbrew/Homebrew"
  mkdir "${HOME}/.linuxbrew/bin"
  ln -s "${HOME}/.linuxbrew/Homebrew/bin/brew" "${HOME}/.linuxbrew/bin"
  eval "$(${HOME}/.linuxbrew/bin/brew shellenv)"
  brew install \
    norwoodj/tap/helm-docs \
    gh \
    hadolint \
    yamllint
EOF3
}

function install_pass() {
  printf "\nInstalling pass ...\n\n"
  apt install -y pass
  git clone https://github.com/nicholaswilde/pass.git "${HOME}/.password-store"
  cd "${HOME}/.password-store"
  git remote set-url origin git@github.com:nicholaswilde/dotfiles.git
}

function install_nano() {
  printf "\nInstalling nanorc ...\n\n"
  curl https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | sudo -u "${TARGET_USER}" bash
  echo "set tabsize 2" >> "${HOME}/.nanorc"
  echo "set tabstospaces" >> "${HOME}/.nanorc"
}

# install custom scripts/binaries
function install_scripts() {
	printf "\nInstalling scripts ...\n\n"
	# install speedtest
	curl -sSL https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py  > /usr/local/bin/speedtest
	chmod +x /usr/local/bin/speedtest

	# install icdiff
	curl -sSL https://raw.githubusercontent.com/jeffkaufman/icdiff/master/icdiff > /usr/local/bin/icdiff
	curl -sSL https://raw.githubusercontent.com/jeffkaufman/icdiff/master/git-icdiff > /usr/local/bin/git-icdiff
	chmod +x /usr/local/bin/icdiff
	chmod +x /usr/local/bin/git-icdiff

	# install lolcat
	curl -sSL https://raw.githubusercontent.com/tehmaze/lolcat/master/lolcat > /usr/local/bin/lolcat
	chmod +x /usr/local/bin/lolcat

	# chromebook
  curl -sSL "https://chromium.googlesource.com/apps/libapps/+/master/hterm/etc/hterm-notify.sh?format=TEXT" | base64 --decode | tee /usr/local/bin/notify
  chmod +x /usr/local/bin/notify
  curl -sSL "https://chromium.googlesource.com/apps/libapps/+/master/hterm/etc/hterm-show-file.sh?format=TEXT" | base64 --decode | tee /usr/local/bin/show-file
  chmod +x /usr/local/bin/show-file
  curl -sSL "https://chromium.googlesource.com/apps/libapps/+/master/hterm/etc/osc52.sh?format=TEXT" | base64 --decode | tee /usr/local/bin/copy
  chmod +x /usr/local/bin/copy
}

function get_dotfiles() {
  # create subshell
sudo -u "${TARGET_USER}" bash <<"EOF"
    cd "$HOME"

    mkdir -p "${HOME}/git/nicholaswilde/"

    git clone https://github.com/nicholaswilde/dotfiles.git "${HOME}/git/nicholaswilde/dotfiles"

    cd "${HOME}/git/nicholaswilde/dotfiles"

    # set the correct origin
    git remote set-url origin git@github.com:nicholaswilde/dotfiles.git

    # installs all the things
    make
EOF
source "${HOME}/.bashrc"
}

function install_tools() {
  install_scripts
  install_nano
  install_pip
  install_rust
  install_golang
  #install_pass
  #install_ruby
  install_brew
}

function main() {
  local cmd=$1
  case "$#" in
    0)
      check_is_sudo
      get_user
      base_min
      install_tools
      get_dotfiles
      return
      ;;
  esac
  case "${cmd}" in
    basemin)
      check_is_sudo
      get_user
      base_min
      ;;
    brew)
      get_user
      install_brew
      ;;
    dotfiles)
      get_user
      get_dotfiles
      ;;
    golang)
      check_is_sudo
      get_user
      install_golang
      ;;
    nano)
      get_user
      install_nano
      ;;
    pass)
      check_is_sudo
      get_user
      install_pass
      ;;
    ruby)
      check_is_sudo
      get_user
      install_ruby
      ;;
    rust)
      get_user
      install_rust
      ;;
    scripts)
      check_is_sudo
        get_user
      install_scripts
      ;;
    tools)
      check_is_sudo
      get_user
      install_tools
      ;;
    *) usage_error;;
  esac
}

main "$@"
