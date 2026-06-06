#!/usr/bin/env bash
set -euo pipefail

echo "=== Verifying Stow Installation ==="

# Check that home directory exists
HOME_DIR="/home/testuser"

# Check standard symlinks
declare -A EXPECTED_LINKS=(
    ["$HOME_DIR/.bashrc"]="$HOME_DIR/dotfiles/bash/.bashrc"
    ["$HOME_DIR/.bash_aliases"]="$HOME_DIR/dotfiles/bash/.bash_aliases"
    ["$HOME_DIR/.config/micro/settings.json"]="$HOME_DIR/dotfiles/micro/.config/micro/settings.json"
    ["$HOME_DIR/.gemini/antigravity-cli/settings.json"]="$HOME_DIR/dotfiles/antigravity-cli/.gemini/antigravity-cli/settings.json"
    ["$HOME_DIR/.antigravity/settings.json"]="$HOME_DIR/dotfiles/antigravity/.antigravity/settings.json"
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

# Check that decryption worked
if [ ! -f "$HOME_DIR/dotfiles/bash/.tokens" ]; then
    echo "FAIL: bash/.tokens was not decrypted"
    failed=1
else
    if [ ! -s "$HOME_DIR/dotfiles/bash/.tokens" ]; then
        echo "FAIL: bash/.tokens is empty"
        failed=1
    else
        echo "PASS: bash/.tokens successfully decrypted and populated"
    fi
fi

if [ $failed -eq 0 ]; then
    echo "=== ALL TESTS PASSED SUCCESSFULLY ==="
    exit 0
else
    echo "=== SOME TESTS FAILED ==="
    exit 1
fi
