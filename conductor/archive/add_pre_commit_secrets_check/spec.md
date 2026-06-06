# Specification - Add Pre-Commit Hook for Secrets Verification

## Overview
The goal of this track is to add a security check to protect the repository from accidental commits of unencrypted secrets files (like `.tokens`, `settings.json`, and `mcp_config.json` that belong in Git ignores).

## Requirements
1. **Validation script:** Create a script `scripts/check-secrets.sh` that checks currently staged git changes for target unencrypted secrets file extensions or names.
2. **Task Integration:** Add a `check-secrets` task in `Taskfile.yaml` to run the verification script.
3. **Git Hook installation:** Provide instructions or a task to link the script to the local `.git/hooks/pre-commit` file.
4. **Testing:** Test that trying to commit a dummy `settings.json` file fails as expected, and committing a normal file succeeds.
