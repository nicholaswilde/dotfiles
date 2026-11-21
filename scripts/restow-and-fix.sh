#!/usr/bin/env bash
set -euo pipefail

# Helper script for restow skill.
# Cleans legacy GNU Stow folded directory symlinks and dangling repo symlinks,
# restows packages with enstow (backing up conflicting unmanaged files),
# and verifies links and secret hygiene.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

TARGET_DIR="${HOME}"
CONFIG_FILE="${REPO_ROOT}/.enstow.toml"
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
    --config|-C)
      CONFIG_FILE="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: restow-and-fix.sh [--dry-run] [--target <dir>] [--config <file>] [package1 package2 ...]"
      exit 0
      ;;
    *)
      PACKAGES+=("$1")
      shift
      ;;
  esac
done

if ! command -v enstow >/dev/null 2>&1; then
  echo "ERROR: enstow is not installed or not in PATH." >&2
  exit 1
fi

if [[ ! -f "${CONFIG_FILE}" ]]; then
  echo "ERROR: ${CONFIG_FILE} not found." >&2
  exit 1
fi

echo "=== Restowing dotfiles with enstow to ${TARGET_DIR} ==="

# Step 1: Unlink legacy GNU Stow folded directory symlinks & dangling symlinks pointing into this repo
legacy_cleaned=0
while IFS= read -r -d '' link; do
  resolved=$(readlink -m "$link" 2>/dev/null || true)
  if [[ "$resolved" == "${REPO_ROOT}/"* ]]; then
    if [[ ! -e "$link" ]] || [[ -d "$resolved" ]]; then
      if [[ "$DRY_RUN" -eq 1 ]]; then
        echo "WOULD UNLINK legacy/dangling symlink: ${link} -> $(readlink "$link")"
      else
        echo "Unlinking legacy/dangling symlink: ${link} -> $(readlink "$link")"
        rm -f "$link"
      fi
      legacy_cleaned=$((legacy_cleaned + 1))
    fi
  fi
done < <(find "${TARGET_DIR}" -maxdepth 4 -type l -print0 2>/dev/null)

if [[ "$legacy_cleaned" -gt 0 ]]; then
  echo "Legacy/dangling symlinks $([[ "$DRY_RUN" -eq 1 ]] && echo 'found' || echo 'cleaned'): ${legacy_cleaned}"
fi

# Step 2: Restow packages via enstow with backup for unmanaged target collisions
ENSTOW_CMD=(
  enstow
  -C "${CONFIG_FILE}"
  -s "${REPO_ROOT}"
  -t "${TARGET_DIR}"
  restow
  --backup
  --backup-dir "${BACKUP_DIR}"
)

if [[ "$DRY_RUN" -eq 1 ]]; then
  ENSTOW_CMD+=(--dry-run)
fi

if [[ ${#PACKAGES[@]} -gt 0 ]]; then
  ENSTOW_CMD+=("${PACKAGES[@]}")
fi

"${ENSTOW_CMD[@]}"

if [[ "$DRY_RUN" -eq 0 ]] && [[ -d "${BACKUP_DIR}" ]]; then
  echo "Conflicting files backed up to: ${BACKUP_DIR}"
fi

# Step 3: Run verification & secret checks on live HOME restow
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
