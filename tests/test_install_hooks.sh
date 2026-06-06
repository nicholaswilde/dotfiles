#!/usr/bin/env bash
set -euo pipefail

echo "=== Running unit test for task install-hooks ==="

# Clean up any existing pre-commit hook in .git/hooks
rm -f .git/hooks/pre-commit

# Run task install-hooks
if ! task install-hooks >/dev/null 2>&1; then
  echo "FAIL: task install-hooks failed or does not exist"
  exit 1
fi

# Verify symlink exists
if [ ! -L .git/hooks/pre-commit ]; then
  echo "FAIL: .git/hooks/pre-commit is not a symlink"
  exit 1
fi

# Verify symlink target is correct
target=$(readlink .git/hooks/pre-commit)
if [ "$target" != "../../scripts/check-secrets.sh" ]; then
  echo "FAIL: symlink target is $target, expected ../../scripts/check-secrets.sh"
  exit 1
fi

# Verify it is executable
if [ ! -x .git/hooks/pre-commit ]; then
  echo "FAIL: .git/hooks/pre-commit is not executable"
  exit 1
fi

echo "PASS: task install-hooks works perfectly!"
exit 0
