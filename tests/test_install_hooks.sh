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

# Verify pre-commit hook file exists and is executable
if [ ! -f .git/hooks/pre-commit ]; then
  echo "FAIL: .git/hooks/pre-commit does not exist"
  exit 1
fi

if [ ! -x .git/hooks/pre-commit ]; then
  echo "FAIL: .git/hooks/pre-commit is not executable"
  exit 1
fi

# Verify hook invokes enstow doctor --staged
if ! grep -q "enstow doctor --staged" .git/hooks/pre-commit; then
  echo "FAIL: .git/hooks/pre-commit does not invoke enstow doctor --staged"
  exit 1
fi

echo "PASS: task install-hooks works perfectly!"
exit 0
