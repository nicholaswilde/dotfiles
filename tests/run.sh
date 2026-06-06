#!/usr/bin/env bash
set -euo pipefail

# Find repository root directory
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=== Building Debian Docker Test Image ==="
docker build --load -t dotfiles-test-env -f "${REPO_ROOT}/tests/Dockerfile" "${REPO_ROOT}/tests"

echo "=== Running Integration Test inside Container ==="
# Mount the dotfiles repo and the local sops key, then run task bootstrap and verify
docker run --rm \
  -v "${REPO_ROOT}":/home/testuser/dotfiles \
  -v "${HOME}/.config/sops/age/keys.txt":/home/testuser/.config/sops/age/keys.txt:ro \
  dotfiles-test-env \
  bash -c "cd /home/testuser/dotfiles && task bootstrap && ./tests/verify.sh"
