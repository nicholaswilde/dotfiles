#!/usr/bin/env bash
set -euo pipefail

# Helper script for restow skill.
# Decrypts SOPS tokens if needed, prunes dangling repo symlinks, resolves
# stow target conflicts (with backup), restows packages, and verifies links.

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
      echo "Usage: restow-and-fix.sh [--dry-run] [--target <dir>] [--packages-file <file>] [package1 package2 ...]"
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
    clean_line=$(echo "$line" | sed 's/#.*//' | xargs)
    [[ -n "$clean_line" ]] && PACKAGES+=("$clean_line")
  done < "${STOW_PACKAGES_FILE}"
fi

extract_conflict_path() {
  local line="$1"
  if [[ "$line" =~ over\ existing\ target\ (.+)\ since\ neither\ a\ link\ nor\ a\ directory ]]; then
    printf '%s\n' "${BASH_REMATCH[1]}"
  elif [[ "$line" =~ existing\ target\ is\ neither\ a\ link\ nor\ a\ directory:\ (.+)$ ]]; then
    printf '%s\n' "${BASH_REMATCH[1]}"
  elif [[ "$line" =~ existing\ target\ is\ not\ owned\ by\ stow:\ (.+)$ ]]; then
    printf '%s\n' "${BASH_REMATCH[1]}"
  fi
}

echo "=== Restowing ${#PACKAGES[@]} packages to ${TARGET_DIR} ==="

# Step 1: Ensure encrypted secrets are decrypted so ~/.tokens isn't dangling
if [[ -f "bash/.tokens.enc" ]] && [[ ! -s "bash/.tokens" ]]; then
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "WARN: bash/.tokens is missing or empty (would run 'task decrypt')."
  elif command -v task >/dev/null 2>&1; then
    echo "Decrypting bash/.tokens via task decrypt..."
    task decrypt >/dev/null
  elif command -v sops >/dev/null 2>&1; then
    echo "Decrypting bash/.tokens via sops..."
    install -m 600 /dev/null ./bash/.tokens
    sops -d --input-type dotenv --output-type dotenv ./bash/.tokens.enc > ./bash/.tokens
  else
    echo "WARN: bash/.tokens missing and neither task nor sops found." >&2
  fi
fi

# Step 2: Prune dangling symlinks in TARGET_DIR pointing into this repo
dangling_fixed=0
while IFS= read -r -d '' link; do
  if [[ ! -e "$link" ]]; then
    resolved=$(readlink -m "$link" 2>/dev/null || true)
    if [[ "$resolved" == "${REPO_ROOT}/"* ]]; then
      if [[ "$DRY_RUN" -eq 1 ]]; then
        echo "WOULD REMOVE dangling symlink: ${link} -> $(readlink "$link")"
      else
        echo "Removing dangling symlink: ${link} -> $(readlink "$link")"
        rm -f "$link"
      fi
      dangling_fixed=$((dangling_fixed + 1))
    fi
  fi
done < <(find "${TARGET_DIR}" -maxdepth 4 -type l -print0 2>/dev/null)

# Step 3: Detect conflicts per package and restow
conflicts_fixed=0

for pkg in "${PACKAGES[@]}"; do
  if [[ ! -d "$pkg" ]]; then
    echo "WARN: Package directory '$pkg' does not exist in repository. Skipping." >&2
    continue
  fi

  # Dry-run WITHOUT --adopt so GNU Stow reports all target conflicts
  stow_err=$(stow -n -R -t "${TARGET_DIR}" "$pkg" 2>&1 || true)

  while IFS= read -r line; do
    rel_path=$(extract_conflict_path "$line" || true)
    [[ -z "$rel_path" ]] && continue

    target_file="${TARGET_DIR}/${rel_path}"
    source_file="${pkg}/${rel_path}"

    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "CONFLICT ($pkg): ${target_file}"
      conflicts_fixed=$((conflicts_fixed + 1))
      continue
    fi

    if [[ -L "$target_file" ]]; then
      if [[ ! -e "$target_file" ]]; then
        echo "  Removing dangling conflicting symlink: ${target_file}"
        rm -f "$target_file"
      else
        mkdir -p "${BACKUP_DIR}/$(dirname "$rel_path")"
        echo "  Backing up foreign symlink to ${BACKUP_DIR}/${rel_path}..."
        mv "$target_file" "${BACKUP_DIR}/${rel_path}"
      fi
      conflicts_fixed=$((conflicts_fixed + 1))
    elif [[ -f "$target_file" ]]; then
      if [[ -f "$source_file" ]] && cmp -s "$target_file" "$source_file" 2>/dev/null; then
        echo "  Removing identical non-symlink: ${target_file}"
        rm -f "$target_file"
      else
        mkdir -p "${BACKUP_DIR}/$(dirname "$rel_path")"
        echo "  Backing up modified file to ${BACKUP_DIR}/${rel_path}..."
        mv "$target_file" "${BACKUP_DIR}/${rel_path}"
      fi
      conflicts_fixed=$((conflicts_fixed + 1))
    fi
  done <<< "$stow_err"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    stow -n -v -R -t "${TARGET_DIR}" "$pkg" 2>&1 || true
  else
    if ! stow -v -R -t "${TARGET_DIR}" "$pkg" >/dev/null 2>&1; then
      echo "RETRY: Retrying stow with --adopt for package: $pkg"
      stow -v -R --adopt -t "${TARGET_DIR}" "$pkg"
      git restore "$pkg" 2>/dev/null || true
    fi
  fi
done

if [[ "$dangling_fixed" -gt 0 ]]; then
  echo "Dangling symlinks $([[ "$DRY_RUN" -eq 1 ]] && echo 'found' || echo 'cleaned'): ${dangling_fixed}"
fi
if [[ "$conflicts_fixed" -gt 0 ]]; then
  echo "Conflicts $([[ "$DRY_RUN" -eq 1 ]] && echo 'detected' || echo 'resolved'): ${conflicts_fixed}"
  [[ -d "${BACKUP_DIR}" ]] && echo "Backups saved to: ${BACKUP_DIR}"
fi

# Step 4: Run verification & secret checks on live HOME restow
if [[ "$DRY_RUN" -eq 0 ]] && [[ "${TARGET_DIR}" == "${HOME}" ]]; then
  if [[ -f "tests/verify.sh" ]]; then
    echo "Running verification suite: tests/verify.sh..."
    bash tests/verify.sh
  fi
  if command -v task >/dev/null 2>&1; then
    task check-secrets
  elif [[ -x "scripts/check-secrets.sh" ]]; then
    ./scripts/check-secrets.sh
  fi
fi

echo "SUCCESS: All packages restowed cleanly."
exit 0
