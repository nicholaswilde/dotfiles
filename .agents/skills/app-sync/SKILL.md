---
name: app-sync
description: >-
  Commit and push local dotfile changes for a package, then pull and restart services on a target Proxmox LXC container.
  Trigger: "/app sync", "sync app to lxc", "push and pull dotfiles".
---

# App Sync Skill

Synchronizes local dotfile package updates to remote repository and target Proxmox LXC container.

## Protocol

1. **Verify Secrets & Stage**:
   - Inspect `rtk git status` for modified files in `<app_name>/`.
   - Run `task check-secrets` (and `task doctor`) to verify no unencrypted secrets are staged.
   - Stage files explicitly by name (never `git add .` when untracked secret files exist).

2. **Commit & Push**:
   - Commit with Conventional Commits (include `Fixes #<number>` to auto-close linked GitHub issues):

     ```bash
     rtk git commit -m "chore(<app_name>): Update configuration

     Fixes #<number>"
     ```

   - Push to `main`: `rtk git push origin main`.

3. **Remote Pull & Restow**:
   - Connect to target LXC via SSH, run `task update` (or `git pull origin main && task restow`, which applies symlinks and decrypts `.age` secrets in memory via `enstow`).

4. **Restart Service**:
   - Restart associated service on target host if applicable (e.g., `systemctl restart <app_name>`).
