#!/usr/bin/env bash
set -euo pipefail

echo "=== Running unit test for task check-secrets ==="

# Check that task check-secrets exists and runs successfully when nothing is staged
if ! task check-secrets >/dev/null 2>&1; then
  echo "FAIL: task check-secrets failed or does not exist"
  exit 1
fi

# Stage a dummy secret
touch bash/.tokens
git add -f bash/.tokens

# Run task check-secrets; it should fail
if task check-secrets >/dev/null 2>&1; then
  echo "FAIL: task check-secrets succeeded but should have failed on staged secrets"
  git reset -q bash/.tokens
  rm -f bash/.tokens
  exit 1
fi

# Cleanup
git reset -q bash/.tokens
rm -f bash/.tokens

echo "PASS: task check-secrets behaves correctly!"
exit 0
