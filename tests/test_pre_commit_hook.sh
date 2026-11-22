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
git config commit.gpgsign false

# Install enstow doctor --staged pre-commit hook
mkdir -p .git/hooks
cat <<'EOF' > .git/hooks/pre-commit
#!/usr/bin/env sh
exec enstow doctor --staged -s .
EOF
chmod +x .git/hooks/pre-commit

# Seed encrypted counterpart
mkdir -p bash
echo "encrypted_stub" > bash/.tokens.age

# 1. Test normal commit succeeds
echo "normal content" > README.md
git add README.md bash/.tokens.age
if ! git commit -m "chore: initial commit" -q; then
  echo "FAIL: git commit failed for normal file"
  exit 1
fi
echo "PASS: git commit succeeded for normal file"

# 2. Test staged plaintext secret counterpart blocks the commit
echo "secret_value" > bash/.tokens
git add bash/.tokens

if git commit -m "add secrets" -q 2>/dev/null; then
  echo "FAIL: git commit succeeded but should have failed on secret bash/.tokens"
  exit 1
fi
echo "PASS: git commit failed on secret bash/.tokens as expected"
git reset -q bash/.tokens
rm -f bash/.tokens

# 3. Test staged .env file blocks the commit
mkdir -p some/folder
echo "env_secret" > some/folder/.env
git add some/folder/.env

if git commit -m "add env file" -q 2>/dev/null; then
  echo "FAIL: git commit succeeded but should have failed on staged .env file"
  exit 1
fi
echo "PASS: git commit failed on staged .env file as expected"

echo "=== All pre-commit hook tests passed successfully! ==="
exit 0
