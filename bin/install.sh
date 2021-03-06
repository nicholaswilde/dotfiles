#!/bin/bash
set -e
set -o pipefail

export DEBIAN_FRONTEND=noninteractive

function usage() {
  echo -e "install.sh\\n\\tThis script installs my basic setup for a debian computer\\n"
  echo "Usage:"
  echo "  base                                - setup sources & install base pkgs"
  echo "  dotfiles                            - get dotfiles"
}

function main() {
  local cmd=$1
  if [[ -z "$cmd" ]]; then
    usage
    exit 1
  fi
}

main "$@"
