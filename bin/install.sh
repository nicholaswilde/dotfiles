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
  echo "  basemin       - setup sources & install base pkgs"
  echo "  brew          - get brew"
  echo "  docker        - get docker"
  echo "  dotfiles      - get dotfiles"
  echo "  rust          - get rust"
  echo "  golang        - get golang"
  echo "  nano          - setup nanorc files"
  echo "  pass          - get pass"
  echo "  pip           - get pip packages"
  echo "  rust          - get rust"
  echo "  scripts       - get scripts"
  echo "  task          - get task"
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
    nfs-common \
    nodejs \
    npm \
    openssh-client \
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

function install_docker() {
  printf "\nInstalling docker ...\n\n"
  curl -sSL https://get.docker.com | bash
  usermod -aG docker "${TARGET_USER}"
  curl -fsSL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  # Start the service
  service docker start
sudo -u "${TARGET_USER}" bash <<"EOF7"
  # Setup builder
  docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
  mkdir -p "${HOME}/.docker/cli-plugins"
  curl -L "https://github.com/docker/buildx/releases/download/v0.5.1/buildx-v0.5.1.linux-amd64" -O "${HOME}/.docker/cli-plugins/docker-buildx"
  chmod a+x "${HOME}/.docker/cli-plugins/docker-buildx"
  docker buildx install
  docker buildx create --name mybuilder
  docker buildx use mybuilder
  docker buildx inspect --bootstrap
EOF7
}

function install_ssh() {
sudo -u "${TARGET_USER}" bash <<"EOF8"
  mkdir -p "${HOME}/.ssh"
  scp pi@192.168.1.192:~/.ssh/id_rsa "${HOME}/.ssh/id_rsa"
  chmod 0600 "${HOME}/.ssh/id_rsa"
  chmod 0700 "${HOME}/.ssh/"
EOF8
}

function install_task() {
  printf "\nInstalling task ...\n\n"
  sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin
}

# install/update golang from source
function install_golang() {
  printf "\nInstalling golang ...\n\n"
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
  pip install --user ansible
EOF2
}

function install_ruby() {
  printf "\nInstalling ruby ...\n\n"
  apt-get install -y \
    rbenv \
    libssl-dev
sudo -u "${TARGET_USER}" bash <<"EOF4"
  # if we are passing the version
  if [[ -n "$1" ]]; then
    RUBY_VERSION=$1
  else
    RUBY_VERSION="$(rbenv install -l | grep -v - | tail -1)"
  fi
  git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
  rbenv install "${RUBY_VERSION}"
  rbenv global "${RUBY_VERSION}"
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
    yamllint \
    helm
EOF3
}

function install_pass() {
  printf "\nInstalling pass ...\n\n"
  apt install -y pass
  git clone https://github.com/nicholaswilde/pass.git "${HOME}/.password-store"
  cd "${HOME}/.password-store"
  git remote set-url origin git@github.com:nicholaswilde/dotfiles.git
}

function install_kubectl() {
  printf "\nInstalling kubectl ...\n\n"
  apt update
  apt install -y \
    apt-transport-https \
    gnupg2 \
    curl
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
  apt update
  apt install -y kubectl

sudo -u "${TARGET_USER}" bash <<"EOF6"
  # krew
  set -x; cd "$(mktemp -d)"
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.tar.gz"
  tar zxvf krew.tar.gz
  KREW=./krew-"$(uname | tr '[:upper:]' '[:lower:]')_$(uname -m | sed -e 's/x86_64/amd64/' -e 's/arm.*$/arm/' -e 's/aarch64$/arm64/')"
  "$KREW" install krew
  export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
  # ns
  kubectl krew install ns
EOF6
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

  # knsk
  curl -sSL https://raw.githubusercontent.com/thyarles/knsk/master/knsk.sh > /usr/local/bin/knsk
  chmod +x /usr/local/bin/knsk
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
  # shellcheck disable=SC1090
  source "${HOME}/.bashrc"
}

function install_tools() {
  install_scripts
  install_nano
  install_docker
  install_pip
  install_rust
  install_golang "$@"
  install_kubectl
  install_task
  #install_pass
  #install_ruby "$@"
  install_brew
}

function main() {
  local cmd=$1
  case "$#" in
    0)
      check_is_sudo
      get_user
      base_min
      install_tools "$@"
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
    docker)
      check_is_sudo
      get_user
      install_docker
      ;;
    dotfiles)
      get_user
      get_dotfiles
      ;;
    golang)
      check_is_sudo
      get_user
      install_golang "$@"
      ;;
    kubectl)
      check_is_sudo
      get_user
      install_kubectl
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
    pip)
      get_user
      install_pip
      ;;
    ruby)
      check_is_sudo
      get_user
      install_ruby "$@"
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
    task)
      check_is_sudo
      get_user
      install_task
      ;;
    tools)
      check_is_sudo
      get_user
      install_tools "$@"
      ;;
    *) usage_error;;
  esac
}

main "$@"
