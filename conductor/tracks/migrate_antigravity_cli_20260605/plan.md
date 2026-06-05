# Implementation Plan - Migrate Antigravity CLI Configurations

This track details the migration of `~/.gemini/antigravity-cli` configurations into the dotfiles repository.

## Phase 1: Directory Setup & File Backup
- [x] Task: Create directory structure `antigravity-cli/.gemini/antigravity-cli/` (a5cb6a1)
- [x] Task: Copy the `skills/` directory from `~/.gemini/antigravity-cli/skills/` to `antigravity-cli/.gemini/antigravity-cli/skills/` (b90c9de)
- [ ] Task: Copy `settings.json` from `~/.gemini/antigravity-cli/settings.json` to `antigravity-cli/.gemini/antigravity-cli/settings.json`
- [ ] Task: Copy `mcp_config.json` from `~/.gemini/antigravity-cli/mcp_config.json` to `antigravity-cli/.gemini/antigravity-cli/mcp_config.json`
- [ ] Task: Conductor - User Manual Verification 'Phase 1: Directory Setup & File Backup' (Protocol in workflow.md)

## Phase 2: Security & Git Configuration
- [ ] Task: Add `antigravity-cli/.gemini/antigravity-cli/mcp_config.json` to the root `.gitignore` file
- [ ] Task: Create `antigravity-cli/.stow-local-ignore` and ignore `mcp_config.json`
- [ ] Task: Encrypt `antigravity-cli/.gemini/antigravity-cli/mcp_config.json` using SOPS to `antigravity-cli/.gemini/antigravity-cli/mcp_config.json.enc`
- [ ] Task: Conductor - User Manual Verification 'Phase 2: Security & Git Configuration' (Protocol in workflow.md)

## Phase 3: Taskfile Integration
- [ ] Task: Update `Taskfile.yaml` to decrypt/encrypt `mcp_config.json` in the new `antigravity-cli` package
- [ ] Task: Test decryption and encryption tasks using `task decrypt` and `task encrypt`
- [ ] Task: Conductor - User Manual Verification 'Phase 3: Taskfile Integration' (Protocol in workflow.md)

## Phase 4: Stow Installation & Verification
- [ ] Task: Run `task test` to verify the stow dry run does not cause conflicts
- [ ] Task: Run `task install` (or `stow -v -t ~/ antigravity-cli`) to apply the package and link it back to `~/.gemini/antigravity-cli/`
- [ ] Task: Verify that files are correctly symlinked and active
- [ ] Task: Conductor - User Manual Verification 'Phase 4: Stow Installation & Verification' (Protocol in workflow.md)
