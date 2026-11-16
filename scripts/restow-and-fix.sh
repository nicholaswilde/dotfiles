#!/usr/bin/env bash
set -euo pipefail

# Helper script for restow skill.
# Restows packages from .stow-packages, detects and resolves non-symlink conflicts,
# backs up conflicting target files, and verifies link integrity.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

TARGET_DIR="${HOME}"
STOW_PACKAGES_FILE=".stow-packages"
BACKUP_DIR="${HOME}/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
PACKAGES=()
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run|-n)
      DRY_RUN=1
      shift
      ;;
    --target|-t)
      TARGET_DIR="$2"
      shift 2
      ;;
    --packages-file|-f)
      STOW_PACKAGES_FILE="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: restow-and-fix.sh [--dry-run] [--target <dir>] [package1 package2 ...]"
      exit 0
      ;;
    *)
      PACKAGES+=("$1")
      shift
      ;;
  esac
done

if [[ ${#PACKAGES[@]} -eq 0 ]]; then
  if [[ ! -f "${STOW_PACKAGES_FILE}" ]]; then
    echo "ERROR: ${STOW_PACKAGES_FILE} not found." >&2
    exit 1
  fi
  while IFS= read -r line || [[ -n "$line" ]]; do
    # Strip comments and trim whitespace
    clean_line=$(echo "$line" | sed 's/#.*//' | xargs)
    [[ -n "$clean_line" ]] && PACKAGES+=("$clean_line")
  done < "${STOW_PACKAGES_FILE}"
fi

echo "=== Restowing ${#PACKAGES[@]} packages to ${TARGET_DIR} ==="
conflicts_fixed=0

for pkg in "${PACKAGES[@]}"; do
  if [[ ! -d "$pkg" ]]; then
    echo "WARN: Package directory '$pkg' does not exist in repository. Skipping." >&2
    continue
  fi

  # Step 1: Dry run to detect conflict diagnostics
  stow_err=$(stow -n -v -R --adopt -t "${TARGET_DIR}" "$pkg" 2>&1 || true)

  if echo "$stow_err" | grep -q "existing target is neither a link nor a directory"; then
    echo "Resolving non-symlink conflicts in package: $pkg..."
    # Extract conflicting relative paths
    while IFS= read -r conflict_line; do
      rel_path=$(echo "$conflict_line" | sed -n 's/.*existing target is neither a link nor a directory: //p' | xargs)
      if [[ -n "$rel_path" ]]; then
        target_file="${TARGET_DIR}/${rel_path}"
        source_file="${pkg}/${rel_path}"
        if [[ -f "$target_file" ]] && [[ ! -L "$target_file" ]]; then
          if cmp -s "$target_file" "$source_file" 2>/dev/null; then
            echo "  Removing identical non-symlink: ${target_file}"
            rm -f "$target_file"
          else
            mkdir -p "${BACKUP_DIR}/$(dirname "$rel_path")"
            echo "  Backing up modified file to ${BACKUP_DIR}/${rel_path}..."
            mv "$target_file" "${BACKUP_DIR}/${rel_path}"
          fi
          conflicts_fixed=$((conflicts_fixed + 1))
        fi
      fi
    done <<< "$stow_err"
  fi

  # Step 2: Perform restow
  if [[ "$DRY_RUN" -eq 1 ]]; then
    stow -n -v -R --adopt -t "${TARGET_DIR}" "$pkg"
  else
    stow -v -R --adopt -t "${TARGET_DIR}" "$pkg" >/dev/null 2>&1 || {
      echo "RETRY: Retrying stow with adopt for package: $pkg"
      stow -v -R --adopt -t "${TARGET_DIR}" "$pkg"
    }
    # Restore any tracked files modified by --adopt
    git restore "$pkg" 2>/dev/null || true
  fi
done

if [[ "$conflicts_fixed" -gt 0 ]]; then
  echo "Resolved ${conflicts_fixed} conflicts."
  [[ -d "${BACKUP_DIR}" ]] && echo "Backups saved to: ${BACKUP_DIR}"
fi

# Step 3: Run verification if present
if [[ -f "tests/verify.sh" ]] && [[ "$DRY_RUN" -eq 0 ]]; then
  echo "Running verification suite: tests/verify.sh..."
  bash tests/verify.sh
fi

echo "SUCCESS: All packages restowed cleanly."
exit 0
