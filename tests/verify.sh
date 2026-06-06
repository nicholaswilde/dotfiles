#!/usr/bin/env bash
set -euo pipefail

echo "=== Verifying Stow Installation ==="

# Check that home directory exists
HOME_DIR="${HOME}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Check standard symlinks
declare -A EXPECTED_LINKS=(
    ["$HOME_DIR/.bashrc"]="$REPO_ROOT/bash/.bashrc"
    ["$HOME_DIR/.bash_aliases"]="$REPO_ROOT/bash/.bash_aliases"
    ["$HOME_DIR/.config/micro/settings.json"]="$REPO_ROOT/micro/.config/micro/settings.json"
    ["$HOME_DIR/.gemini/antigravity-cli/settings.json"]="$REPO_ROOT/antigravity-cli/.gemini/antigravity-cli/settings.json"
    ["$HOME_DIR/.antigravity/settings.json"]="$REPO_ROOT/antigravity/.antigravity/settings.json"
)

failed=0
for link in "${!EXPECTED_LINKS[@]}"; do
    target="${EXPECTED_LINKS[$link]}"
    if [ ! -e "$link" ]; then
        echo "FAIL: $link does not exist"
        failed=1
    else
        resolved=$(readlink -f "$link")
        if [ "$resolved" != "$target" ]; then
            echo "FAIL: $link resolves to $resolved (expected $target)"
            failed=1
        else
            echo "PASS: $link correctly resolves to $target"
        fi
    fi
done

# Check that decryption/mocking worked
if [ ! -f "$REPO_ROOT/bash/.tokens" ]; then
    echo "FAIL: bash/.tokens was not decrypted/mocked"
    failed=1
else
    if [ ! -s "$REPO_ROOT/bash/.tokens" ]; then
        echo "FAIL: bash/.tokens is empty"
        failed=1
    else
        echo "PASS: bash/.tokens successfully decrypted/mocked and populated"
    fi
fi

if [ $failed -eq 0 ]; then
    echo "=== ALL TESTS PASSED SUCCESSFULLY ==="
    exit 0
else
    echo "=== SOME TESTS FAILED ==="
    exit 1
fi
