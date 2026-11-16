# Specification - Migrate Antigravity CLI Configurations

## Overview
The goal of this track is to migrate key configurations of the Antigravity CLI from `~/.gemini/antigravity-cli/` to the dotfiles repository. This will ensure they are version-controlled, reproducible across setups, and managed via GNU Stow.

## Targeted Files
We are only interested in backing up:
1. `~/.gemini/antigravity-cli/skills/` directory and its contents.
2. `~/.gemini/antigravity-cli/mcp_config.json` (contains secrets).
3. `~/.gemini/antigravity-cli/settings.json` (does not contain secrets).

## Functional Requirements
1. **Repository Structure**: 
   Create a new stow package directory `antigravity-cli` at the root of the dotfiles repository.
   Replicate the home directory path:
   - `antigravity-cli/.gemini/antigravity-cli/`
2. **Copying Configurations**:
   - Copy the files under `~/.gemini/antigravity-cli/skills/` to the new package directory.
   - Copy `settings.json` to the package directory.
   - Copy `mcp_config.json` to the package directory.
3. **Secrets Encryption via SOPS**:
   - `mcp_config.json` contains API keys and tokens. It must be encrypted using `sops -e` and saved as `mcp_config.json.enc`.
   - The plaintext `mcp_config.json` in the package must be added to `.gitignore` and `.stow-local-ignore` to prevent accidental commits.
4. **Stow Integration**:
   - Add task definitions to `Taskfile.yaml` to handle decrypting and encrypting `mcp_config.json` in `antigravity-cli/.gemini/antigravity-cli/`.
   - Update stow commands to install the `antigravity-cli` package.

## Non-Functional Requirements
- **Security**: Plaintext secrets must never be committed to Git.
- **Reproducibility**: Restowing the dotfiles must recreate the correct symlinks under `~/.gemini/antigravity-cli/`.
