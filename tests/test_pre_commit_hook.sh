#!/usr/bin/env bash
set -euo pipefail

# Create a temporary directory for sandboxing git pre-commit hook test
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

echo "=== Running unit test for pre-commit hook execution in $TEST_DIR ==="

# Initialize git repository
cd "$TEST_DIR"
git init -q
git config user.name "Test User"
git config user.email "test@example.com"

# Setup the scripts and hooks folder
mkdir -p scripts
cp /home/nicholas/git/nicholaswilde/dotfiles/scripts/check-secrets.sh scripts/check-secrets.sh
chmod +x scripts/check-secrets.sh

mkdir -p .git/hooks
ln -sf ../../scripts/check-secrets.sh .git/hooks/pre-commit

# 1. Test normal commit succeeds
echo "normal content" > README.md
git add README.md
if ! git commit -m "chore: initial commit" -q; then
  echo "FAIL: git commit failed for normal file"
  exit 1
fi
echo "PASS: git commit succeeded for normal file"

# 2. Test staged secret blocks the commit
mkdir -p bash
echo "secret_value" > bash/.tokens
git add bash/.tokens

# Try to commit - it must fail
if git commit -m "add secrets" -q 2>/dev/null; then
  echo "FAIL: git commit succeeded but should have failed on secret bash/.tokens"
  exit 1
fi

echo "PASS: git commit failed on secret bash/.tokens as expected"

# 3. Test staged .env file blocks the commit
mkdir -p some/folder
echo "env_secret" > some/folder/.env
git add some/folder/.env

# Try to commit - it must fail
if git commit -m "add env file" -q 2>/dev/null; then
  echo "FAIL: git commit succeeded but should have failed on staged .env file"
  exit 1
fi

echo "PASS: git commit failed on staged .env file as expected"

echo "=== All pre-commit hook tests passed successfully! ==="
exit 0
