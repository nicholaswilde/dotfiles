#!/usr/bin/env bash
set -euo pipefail

# Create a temporary directory
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

echo "=== Running unit tests for check-secrets.sh in $TEST_DIR ==="

# Initialize git repo in the temp directory
cd "$TEST_DIR"
git init -q
git config user.name "Test User"
git config user.email "test@example.com"

# Copy the check-secrets.sh script
mkdir -p scripts
cp /home/nicholas/git/nicholaswilde/dotfiles/scripts/check-secrets.sh scripts/check-secrets.sh
chmod +x scripts/check-secrets.sh

# Helper to run script and assert exit code
assert_exit_code() {
  expected_code=$1
  file_to_stage=$2
  description=$3

  # Clear staging area
  git reset -q || true
  rm -f "$file_to_stage"
  git add -A || true

  # Create and stage file
  mkdir -p "$(dirname "$file_to_stage")"
  echo "secret_value" > "$file_to_stage"
  git add "$file_to_stage"

  # Run the script
  if ./scripts/check-secrets.sh >/dev/null 2>&1; then
    actual_code=0
  else
    actual_code=$?
  fi

  if [ "$actual_code" -eq "$expected_code" ]; then
    echo "PASS: $description (Expected $expected_code, got $actual_code)"
  else
    echo "FAIL: $description (Expected $expected_code, got $actual_code)"
    exit 1
  fi
}

# 1. Test standard non-secret file succeeds
assert_exit_code 0 "README.md" "Staged readme file"
assert_exit_code 0 "micro/.config/micro/settings.json" "Staged public settings.json"

# 2. Test forbidden files fail (exit code 1 or similar non-zero)
assert_exit_code 1 "bash/.tokens" "Staged bash/.tokens"
assert_exit_code 1 "antigravity/.antigravity/settings.json" "Staged antigravity settings.json"
assert_exit_code 1 "antigravity-cli/.gemini/antigravity-cli/mcp_config.json" "Staged antigravity-cli mcp_config.json"
assert_exit_code 1 "some/folder/.env" "Staged .env file"

echo "=== All check-secrets.sh tests passed! ==="
