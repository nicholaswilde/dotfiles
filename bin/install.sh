#!/bin/bash
set -e
set -o pipefail

export DEBIAN_FRONTEND=noninteractive

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
      echo "Using user account: ${TARGET_USER}"
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
  echo "  base                                - setup sources & install base pkgs"
  echo "  dotfiles                            - get dotfiles"
}

function base_min() {
  apt update || true
  apt -y upgrade

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
    libc6-dev \
    locales \
    lsof \
    make \
    mount \
    net-tools \
    policykit-1 \
    silversearcher-ag \
    ssh \
    strace \
    sudo \
    tar \
    tree \
    tzdata \
    unzip \
    xz-utils \
    zip \
    --no-install-recommends

  apt autoremove -y
  apt autoclean -y
  apt clean -y
}

function get_dotfiles() {
  # create subshell
  (
  cd "$HOME"

  dir_exists "${HOME}/dotfiles" && git clone https://github.com/nicholaswilde/dotfiles.git "${HOME}/git/nicholaswilde/dotfiles"

  cd "${HOME}/git/nicholaswilde/dotfiles"

  # set the correct origin
  git remote set-url origin git@github.com:nicholaswilde/dotfiles.git

  # installs all the things
  make
  )
}

function main() {
  local cmd=$1
  case "$#" in
    0) usage_error;;
  esac
  case "${cmd}" in
    base_min)
      check_is_sudo
      get_user
      base_min
      ;;
    dotfiles)
      check_is_sudo
      get_user
      install_dotfiles
      ;;
    /?) usage_error;;
  esac
}

main "$@"
