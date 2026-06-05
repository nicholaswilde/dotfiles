# Implementation Plan - Migrate Antigravity CLI Configurations

This track details the migration of `~/.gemini/antigravity-cli` configurations into the dotfiles repository.

## Phase 1: Directory Setup & File Backup [checkpoint: 4b2fce0]
- [x] Task: Create directory structure `antigravity-cli/.gemini/antigravity-cli/` (a5cb6a1)
- [x] Task: Copy the `skills/` directory from `~/.gemini/antigravity-cli/skills/` to `antigravity-cli/.gemini/antigravity-cli/skills/` (b90c9de)
- [x] Task: Copy `settings.json` from `~/.gemini/antigravity-cli/settings.json` to `antigravity-cli/.gemini/antigravity-cli/settings.json` (3597d2d)
- [x] Task: Copy `mcp_config.json` from `~/.gemini/antigravity-cli/mcp_config.json` to `antigravity-cli/.gemini/antigravity-cli/mcp_config.json` (daa48f6)
- [x] Task: Conductor - User Manual Verification 'Phase 1: Directory Setup & File Backup' (Protocol in workflow.md) (4b2fce0)

## Phase 2: Security & Git Configuration [checkpoint: 8e35327]
- [x] Task: Add `antigravity-cli/.gemini/antigravity-cli/mcp_config.json` to the root `.gitignore` file (323bfdd)
- [x] Task: Create `antigravity-cli/.stow-local-ignore` and ignore `mcp_config.json` (eb168e4)
- [x] Task: Encrypt `antigravity-cli/.gemini/antigravity-cli/mcp_config.json` using SOPS to `antigravity-cli/.gemini/antigravity-cli/mcp_config.json.enc` (1cc165b)
- [x] Task: Conductor - User Manual Verification 'Phase 2: Security & Git Configuration' (Protocol in workflow.md) (8e35327)

## Phase 3: Taskfile Integration [checkpoint: 212064b]
- [x] Task: Update `Taskfile.yaml` to decrypt/encrypt `mcp_config.json` in the new `antigravity-cli` package (ebdf62d)
- [x] Task: Test decryption and encryption tasks using `task decrypt` and `task encrypt` (fbe95ee)
- [x] Task: Conductor - User Manual Verification 'Phase 3: Taskfile Integration' (Protocol in workflow.md) (212064b)

## Phase 4: Stow Installation & Verification
- [x] Task: Run `task test` to verify the stow dry run does not cause conflicts (3359598)
- [x] Task: Run `task install` (or `stow -v -t ~/ antigravity-cli`) to apply the package and link it back to `~/.gemini/antigravity-cli/` (2e418c0)
- [x] Task: Verify that files are correctly symlinked and active (a2df4ae)
- [ ] Task: Conductor - User Manual Verification 'Phase 4: Stow Installation & Verification' (Protocol in workflow.md)
