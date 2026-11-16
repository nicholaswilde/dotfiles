---
name: manage-bash-functions
description: Add, modify, or remove shell functions in bash/.bash_functions enforcing inline ## docstrings, local vars, and command_exists guards. Trigger: "manage bash functions", "add bash function", "update .bash_functions".
---

# Manage Bash Functions Skill

Manages shell functions in `bash/.bash_functions`.

## Protocol

1. **Verify Inputs & Guards**:
   - Check name collisions in `bash/.bash_functions` and `bash/.bash_aliases`.
   - Wrap functions requiring optional external tools in `if command_exists <cmd>; then ... fi`.

2. **Format & Document**:
   - Require inline `## <description>` docstring on declaration `{` line and `local` variable scoping:
     ```bash
     if command_exists jq; then
       getcom() { ## Get short commit hash from GitHub repo
         local repo="${1}"
         check_args "getcom <user/repo>" "${repo}" || return 1
         curl -s "https://api.github.com/repos/${repo}/commits" | jq -r '.[0].sha' | head -c 7 && printf "\n"
       }
     fi
     ```

3. **Verify & Commit**:
   - Run `bash -n bash/.bash_functions` and `shuck bash/.bash_functions`.
   - Stage `bash/.bash_functions` explicitly and commit (add `Fixes #<number>` if resolving an issue):
     ```bash
     rtk git commit -m "feat(bash): Add function '<function_name>'"
     ```
