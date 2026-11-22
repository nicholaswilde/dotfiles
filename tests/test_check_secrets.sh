#!/usr/bin/env bash
set -euo pipefail

# Create a temporary directory
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

echo "=== Running unit tests for enstow doctor --staged in $TEST_DIR ==="

# Initialize git repo in the temp directory with encrypted secret counterparts
cd "$TEST_DIR"
git init -q
git config user.name "Test User"
git config user.email "test@example.com"

mkdir -p bash pvetui/.config/pvetui
echo "encrypted_stub" > bash/.tokens.age
echo "encrypted_stub" > pvetui/.config/pvetui/config.yml.age

# Helper to run enstow doctor --staged and assert exit code
assert_exit_code() {
  expected_code=$1
  file_to_stage=$2
  description=$3
  content=${4:-"secret_value"}

  # Clear staging area
  git reset -q || true

  # Create and stage file
  mkdir -p "$(dirname "$file_to_stage")"
  printf '%s\n' "$content" > "$file_to_stage"
  git add "$file_to_stage"

  # Run enstow staged secret guard
  if enstow doctor --staged -s "$TEST_DIR" >/dev/null 2>&1; then
    actual_code=0
  else
    actual_code=$?
  fi

  # Clean up non-.age test artifact
  git reset -q || true
  if [[ "$file_to_stage" != *.age ]]; then
    rm -f "$file_to_stage"
  fi

  if [ "$actual_code" -eq "$expected_code" ]; then
    echo "PASS: $description (Expected $expected_code, got $actual_code)"
  else
    echo "FAIL: $description (Expected $expected_code, got $actual_code)"
    exit 1
  fi
}

# 1. Test standard non-secret, template .env, and encrypted files succeed
assert_exit_code 0 "README.md" "Staged readme file"
assert_exit_code 0 ".env.example" "Staged .env.example template"
assert_exit_code 0 "micro/.config/micro/settings.json" "Staged public settings.json"
assert_exit_code 0 "bash/.tokens.age" "Staged encrypted bash/.tokens.age"
assert_exit_code 0 "pvetui/.config/pvetui/config.yml.age" "Staged encrypted pvetui config.yml.age"

# 2. Test forbidden files and credential leaks fail
assert_exit_code 1 "bash/.tokens" "Staged plaintext counterpart bash/.tokens"
assert_exit_code 1 "pvetui/.config/pvetui/config.yml" "Staged plaintext counterpart pvetui config.yml"
assert_exit_code 1 "some/folder/.env" "Staged .env file"
assert_exit_code 1 "notes.txt" "Staged credential leak" "AGE-SECRET-""KEY-1QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ"

echo "=== All enstow doctor --staged tests passed! ==="
