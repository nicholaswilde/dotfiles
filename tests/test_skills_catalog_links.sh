#!/usr/bin/env bash
set -euo pipefail

echo "=== Running unit test for Agent Skills Catalog links ==="

# Check that skills_catalog.md exists
if [ ! -f .agents/skills_catalog.md ]; then
  echo "FAIL: .agents/skills_catalog.md does not exist"
  exit 1
fi

# Check that conductor/index.md contains a link to it
if ! grep -q "\[Agent Skills Catalog\](\.\./\.agents/skills_catalog\.md)" conductor/index.md; then
  echo "FAIL: conductor/index.md does not contain correct link to skills_catalog.md"
  exit 1
fi

# Verify the three main commands are documented
for cmd in "/app add <path>" "/app check-configs" "/app sync <app_name>"; do
  if ! grep -q "$cmd" .agents/skills_catalog.md; then
    echo "FAIL: Command '$cmd' is not documented in skills_catalog.md"
    exit 1
  fi
done

echo "PASS: Agent Skills Catalog links and commands verified successfully!"
exit 0
