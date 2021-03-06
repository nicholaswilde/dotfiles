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
  echo "  dotfiles                            - get dotfiles"
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
    libc6-dev \
    locales \
    lsof \
    make \
    mount \
    nano \
    net-tools \
    policykit-1 \
    python-is-python3 \
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

function install_nano() {
  printf "\nInstalling nanorc ...\n\n"
  curl https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | sudo -u "${TARGET_USER}" bash
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
}

function install_tools() {
  install_scripts
  install_nano
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
    dotfiles)
      get_user
      get_dotfiles
      ;;
    nano)
      check_is_sudo
      get_user
      install_nano
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
