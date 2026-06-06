#!/usr/bin/env bash
set -euo pipefail

# Forbidden exact paths
forbidden_exact=(
  "bash/.tokens"
  "antigravity/.antigravity/settings.json"
  "antigravity-cli/.gemini/antigravity-cli/mcp_config.json"
)

# Get all staged files (Added, Copied, Modified)
staged_files=$(git diff --cached --name-only --diff-filter=ACM)

failed=0

for file in $staged_files; do
  # Check for exact matches
  for forbidden in "${forbidden_exact[@]}"; do
    if [ "$file" = "$forbidden" ]; then
      echo "ERROR: Attempted to commit unencrypted secret file: $file" >&2
      echo "Please encrypt this file using 'task encrypt' before committing." >&2
      failed=1
    fi
  done

  # Check for files ending in .env or named .env
  if [[ "$file" == *".env" || "$(basename "$file")" == ".env" ]]; then
    echo "ERROR: Attempted to commit unencrypted secret file: $file" >&2
    echo "Never commit .env files to the repository. Please add it to .gitignore or remove it from the staging area." >&2
    failed=1
  fi
done

if [ $failed -eq 1 ]; then
  exit 1
fi

exit 0
