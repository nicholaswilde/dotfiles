#!/usr/bin/env bash
set -euo pipefail

echo "=== Verifying enstow Installation ==="

HOME_DIR="${HOME}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Check standard symlinks
declare -A EXPECTED_LINKS=(
    ["$HOME_DIR/.bashrc"]="$REPO_ROOT/bash/.bashrc"
    ["$HOME_DIR/.bash_aliases"]="$REPO_ROOT/bash/.bash_aliases"
    ["$HOME_DIR/.config/micro/settings.json"]="$REPO_ROOT/micro/.config/micro/settings.json"
)

failed=0
for link in "${!EXPECTED_LINKS[@]}"; do
    target="${EXPECTED_LINKS[$link]}"
    if [ ! -L "$link" ]; then
        echo "FAIL: $link is not a symlink"
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

# Check decrypted secret files deployed by enstow (regular files, non-empty, mode 0600)
EXPECTED_SECRETS=(
    "$HOME_DIR/.tokens"
    "$HOME_DIR/.config/pvetui/config.yml"
)

for secret in "${EXPECTED_SECRETS[@]}"; do
    if [ -L "$secret" ]; then
        echo "FAIL: $secret should be a decrypted regular file, not a symlink"
        failed=1
    elif [ ! -f "$secret" ]; then
        echo "FAIL: $secret was not decrypted"
        failed=1
    elif [ ! -s "$secret" ]; then
        echo "FAIL: $secret is empty"
        failed=1
    else
        perms=$(stat -c '%a' "$secret")
        if [ "$perms" != "600" ]; then
            echo "FAIL: $secret has insecure permissions $perms (expected 600)"
            failed=1
        else
            echo "PASS: $secret decrypted with 0600 permissions"
        fi
    fi
done

# Verify no plaintext secrets exist inside repository working tree
FORBIDDEN_REPO_SECRETS=(
    "$REPO_ROOT/bash/.tokens"
    "$REPO_ROOT/pvetui/.config/pvetui/config.yml"
)

for plaintext in "${FORBIDDEN_REPO_SECRETS[@]}"; do
    if [ -e "$plaintext" ]; then
        echo "FAIL: Plaintext secret exists in repo: $plaintext"
        failed=1
    else
        echo "PASS: No plaintext secret in repo: $plaintext"
    fi
done

# Validate enstow status reports all managed dotfiles and secrets SYNCED
if command -v enstow >/dev/null 2>&1; then
    if enstow -s "$REPO_ROOT" -t "$HOME_DIR" status --check >/dev/null; then
        echo "PASS: enstow status reports all managed dotfiles and secrets SYNCED"
    else
        echo "FAIL: enstow status reported non-synced entries:"
        enstow -s "$REPO_ROOT" -t "$HOME_DIR" status || true
        failed=1
    fi
fi

if [ $failed -eq 0 ]; then
    echo "=== ALL TESTS PASSED SUCCESSFULLY ==="
    exit 0
else
    echo "=== SOME TESTS FAILED ==="
    exit 1
fi
