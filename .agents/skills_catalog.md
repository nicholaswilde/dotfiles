# Agent Skills Catalog

Catalog of custom Antigravity agent skills available in `dotfiles`.

| Skill | Description | Task / Command |
|---|---|---|
| [`add-app`](skills/add-app/SKILL.md) | Add application config, configure `enstow`, encrypt secrets with `age`, update `.enstow.toml` | `/app add <path>` / `task install` |
| [`add-path-to-env`](skills/add-path-to-env/SKILL.md) | Safely add directory paths to `$PATH` in `bash/.bash_exports` with `test -d` guards | `bash -n bash/.bash_exports` |
| [`app-sync`](skills/app-sync/SKILL.md) | Commit, push local package changes, and pull & restart services on Proxmox LXC | `/app sync <app_name>` / `task update` |
| [`audit-eget`](skills/audit-eget/SKILL.md) | Audit `~/.local/bin/` against `eget/.eget.toml`, detect `brew` duplicates, test `eget -D` | `/audit-eget` / `eget -D` |
| [`check-configs`](skills/check-configs/SKILL.md) | Scan `~/.config/` against `.enstow.toml` and recommend configs to manage with `enstow` | `/app check-configs` |
| [`check-secrets`](skills/check-secrets/SKILL.md) | Audit staged files and `enstow` `.age` encrypted secrets across repository | `task check-secrets` / `task doctor` |
| [`commit-dotfiles`](skills/commit-dotfiles/SKILL.md) | Safely audit secrets, run `enstow` dry-run, stage explicitly, commit, and push dotfiles | `/commit-dotfiles` / `task test` |
| [`enforce-automation`](skills/enforce-automation/SKILL.md) | Prioritize `Taskfile.yaml` automation before raw shell execution | `task --list` |
| [`manage-bash-aliases`](skills/manage-bash-aliases/SKILL.md) | Manage conditional aliases in `bash/.bash_aliases` guarded by existence checks | `shuck check bash/.bash_aliases` |
| [`manage-bash-completions`](skills/manage-bash-completions/SKILL.md) | Manage completions, hooks, and evals in `bash/.bash_completions` guarded by `command_exists` | `shuck check bash/.bash_completions` |
| [`manage-bash-exports`](skills/manage-bash-exports/SKILL.md) | Manage env vars and exports in `bash/.bash_exports` with binary/path guards and `bash/.tokens.age` secret routing | `shuck check bash/.bash_exports` |
| [`manage-bash-functions`](skills/manage-bash-functions/SKILL.md) | Manage functions in `bash/.bash_functions` with inline `##` docstrings and `local` vars | `shuck check bash/.bash_functions` |
| [`pull-dotfiles`](skills/pull-dotfiles/SKILL.md) | Pull upstream dotfiles, restow with `enstow`, audit symlinks/secrets, and fix issues | `/pull-dotfiles` / `task update` |
| [`restow`](skills/restow/SKILL.md) | Restow packages with `enstow`, resolve conflicts with backup, verify symlinks and secrets | `task restow:fix` / `task restow` |
| [`verify-bash-configs`](skills/verify-bash-configs/SKILL.md) | Validate syntax, `shuck` lint rules, `##` docstrings, and `enstow` symlinks for `bash/` | `task test` / `shuck check bash/.*` |

---

## Legacy Antigravity Skill Links

Preserved for backward compatibility with [`tests/test_skills_catalog_links.sh`](../tests/test_skills_catalog_links.sh):

- `/app add <path>` — [add_app.md](./antigravity/skills/add_app.md)
- `/app check-configs` — [check_configs.md](./antigravity/skills/check_configs.md)
- `/app sync <app_name>` — See [`app-sync`](skills/app-sync/SKILL.md)
- `Add Path to Environment Variable` — [add_path_to_env.md](./antigravity/skills/add_path_to_env.md)
- `Manage Bash Aliases` — [manage_bash_aliases.md](./antigravity/skills/manage_bash_aliases.md)
- `Manage Bash Functions` — [manage_bash_functions.md](./antigravity/skills/manage_bash_functions.md)
- `Verify Bash Configs` — [verify_bash_configs.md](./antigravity/skills/verify_bash_configs.md)
