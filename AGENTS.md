# AGENTS.md

Conventions and architecture for AI agents working on `dotfiles`.

---

<!-- rtk-begin -->
## RTK Command Guidelines

- **Git Operations**: Prefix `git` commands with `rtk` (e.g., `rtk git status`, `rtk git diff`, `rtk git log`, `rtk git commit`, `rtk git push`).
- **GitHub CLI**: Prefix `gh` commands with `rtk` and pipe to `cat` (e.g., `rtk gh issue list | cat`, `rtk gh pr status | cat`). Always pipe to bypass interactive pagers.
- **File & Directory Inspection**: Use `rtk ls`, `rtk tree`, `rtk find`, `rtk fd`, or `rtk read` when listing or reading files for token-optimized output.
- **Searching**: Use `rtk rg` or `rg` (ripgrep) for line search pattern matching to save tokens.
- **Ripwire Operations**: Prefix `ripwire` commands with `rtk` (e.g., `rtk ripwire <dir> --for="<task>"`). Always invoke via CLI, never register or use MCP.
- **TOML Operations**: Prefix `taplo` commands with `rtk` (e.g., `rtk taplo fmt`, `rtk taplo lint`, `rtk taplo check`).
- **Markdown Operations**: Prefix `rumdl` commands with `rtk` (e.g., `rtk rumdl check .`, `rtk rumdl fmt .`).
- **NPX Operations**: Prefix `npx` commands with `rtk` (e.g., `rtk npx <cmd>`).
- **Build & Test Outputs**: Use `rtk err` or `rtk test` when running build/test commands to filter output to errors/failures only (e.g., `rtk test task test`).
- **Exceptions**: Inside `ctx_execute` / `ctx_batch_execute` sandbox code, skip `rtk` (only printed output enters context). Drop `rtk` when exact raw bytes or patch required (`git diff` patch).
<!-- rtk-end -->

<!-- context-mode-begin -->
## Context-Mode Routing Guidelines

- **Derive, Do Not Dump**: Do NOT use `ctx_execute_file` or `ctx_execute` to dump whole file or full config. Print only specific value, matches, count, or known line range needed.
- **Tool Call Surface**: When using MCP wrappers, call `call_mcp_tool` with `ServerName: "context-mode_context-mode"` and `ToolName: "ctx_execute"`, `"ctx_execute_file"`, `"ctx_batch_execute"`, `"ctx_fetch_and_index"`, `"ctx_search"`, or `"ctx_index"`. Do not duplicate plugin MCP server in `mcp_config.json`.
- **Mandatory Routing**:
  - For analyze/count/filter/compare/search/parse/transform tasks, write code with `ctx_execute` and print only final answer.
  - For analyzing/exploring inside file, use `ctx_execute_file`. Use native `read_file` only when editing requires exact bytes or small known range.
  - Use `ctx_batch_execute` for multi-command repository reconnaissance.
  - Use `ctx_execute` for shell commands whose output may exceed short fixed answer.
  - Use `ctx_fetch_and_index` for web content, then `ctx_search` to query it.
  - Return only derived answers, concise summaries, selected snippets, or file paths.
<!-- context-mode-end -->

<!-- ponytail-begin -->
## Ponytail (Lazy Senior Dev Mode) Guidelines

- **Stop at first rung that holds**:
  1. Need to build at all? (YAGNI)
  2. Already in codebase? Reuse existing helpers/utils/patterns.
  3. Stdlib does it? Use it.
  4. Native platform feature covers it? Use it.
  5. Installed dependency solves it? Use it.
  6. Can be one line? One line.
  7. Only then: write minimum working code.
- **Bug fix = root cause, not symptom**: Fix shared function/path rather than individual callers.
- **Rules**:
  - No unrequested abstractions, boilerplate, or avoidable dependencies.
  - Deletion over addition. Boring over clever. Fewest files possible.
  - Shortest working diff wins once problem understood.
  - Mark deliberate simplifications cutting real corner with `ponytail:` comment naming ceiling and upgrade path.
  - Ensure logic leaves behind ONE runnable check. Trivial one-liners need none.
<!-- ponytail-end -->

<!-- caveman-begin -->
## Caveman Guidelines

Respond terse like smart caveman. All technical substance stay. Only fluff die.

Rules:

- Drop: articles (a/an/the), filler (just/really/basically), pleasantries, hedging.
- Fragments OK. Short synonyms. Technical terms exact. Code unchanged.
- Pattern: [thing] [action] [reason]. [next step].
- Not: "Sure! I'd be happy to help you with that."
- Yes: "Bug in auth middleware. Fix:"

Switch level: /caveman lite|full|ultra|wenyan
Stop: "stop caveman" or "normal mode"

Auto-Clarity: drop caveman for security warnings, irreversible actions, user confused. Resume after.

Boundaries: code/commits/PRs written normal.
<!-- caveman-end -->

<!-- codegraph-begin -->
## CodeGraph

In repositories indexed by CodeGraph (`.codegraph/` directory exists at repo root), reach for it BEFORE grep/find or reading files when exploring code:

- **MCP tool**: `codegraph_explore` answers source + call path + blast radius in one call. Dynamic-dispatch hops included. Name file or symbol in query to read current line-numbered source.
- **Shell**: `codegraph explore "<symbol names or question>"`.

If no `.codegraph/` directory exists, skip CodeGraph entirely.
<!-- codegraph-end -->

<!-- serena-begin -->
## Serena Semantic Navigation & LSP Integration

Use Serena (`serena`) MCP tools for semantic navigation, AST symbol inspection, LSP diagnostics, and project memories:

1. **Map first**: Call `get_symbols_overview` on target file instead of reading entire file.
2. **Read target symbol only**: Call `find_symbol` with `include_body: true` for target function/class/method.
3. **Check callers**: Call `find_referencing_symbols` or `find_implementations` before signature or behavior changes.
4. **Edit by symbol**: Use `replace_symbol_body`, `insert_after_symbol`, `insert_before_symbol`, or `rename_symbol`. Use standard edit for small tweaks or non-code files.
5. **Verify diagnostics**: Call `get_diagnostics_for_file` after edits to catch LSP errors before full test run.
<!-- serena-end -->

<!-- headroom-begin -->
## Headroom MCP (Context Window Compression)

Use Headroom (`headroom`) MCP tools to manage context window consumption on large payloads:

- `headroom_compress`: Shrink large tool outputs or raw data.
- `headroom_retrieve`: Retrieve original content by hash if specific details needed.
- `headroom_stats`: Monitor headroom cache usage.
<!-- headroom-end -->

<!-- ripwire-begin -->
## Ripwire CLI Guidelines

Use `ripwire` CLI (prefixed with `rtk ripwire`) for AST codebase mapping, call graphs, blast radius, and structural queries:

- **CLI First**: Always invoke `rtk ripwire <dir> [flags]` via CLI; do NOT use MCP server.
- **Task Orientation**: `rtk ripwire <dir> --for="<task>"` for ranked signatures and bodies.
- **Task Bundle**: `rtk ripwire <dir> --pack-task="<task>" --legend=compact`.
- **Stack Trace / Error**: `rtk ripwire <dir> --from-trace=FILE --legend=compact` (`-` for stdin).
- **Call Graph**: `rtk ripwire <dir> --callers=SYM`, `--callees=SYM`, `--uses=SYM`.
- **Blast Radius**: `rtk ripwire <dir> --impact=SYM --legend=compact` before changing shared code.
- **Quality Delta & Gate**: `rtk ripwire <dir> --quality-delta --legend=compact` and `--test-gate --legend=compact`.
- **Atomic Edits**: `rtk ripwire <dir> --replace-symbol-body=SYM --edit-payload=FILE` without whole-file re-reading.
<!-- ripwire-end -->

<!-- ripgrep-guidelines-begin -->
## Ripgrep Guidelines

- **Pattern Searching**: Always use `rg` (ripgrep) or `rtk rg` instead of standard `grep` to search text inside files quickly and save token output.
- **Scope**: Use `-t sh` for shell files, `-l` for file listing, keep context small (`-C 1`).
<!-- ripgrep-guidelines-end -->

<!-- taplo-rules-begin -->
## Taplo TOML Rules

- **Prefix with RTK**: Always prefix `taplo` commands with `rtk` in interactive shells (e.g., `rtk taplo fmt`, `rtk taplo lint`).
- **Format**: Run `rtk taplo fmt` to format TOML files in-place (`.enstow.toml`, `mise/.config/mise/config.toml`, `eget/.eget.toml`).
- **Validation**: Run `rtk taplo lint` to validate TOML syntax and schema.
<!-- taplo-rules-end -->

<!-- issue-management-begin -->
## GitHub Issue Management

Track features and bugs via remote GitHub issues (`rtk gh issue ... | cat`), not local Conductor tracks:

- **Features**: Prefix title with `[feat]: ` and apply `enhancement` label.
- **Bugs**: Prefix title with `[bug]: ` and apply `bug` label.
- **Commit Closing**: GitHub issues only close automatically when commits containing `Fixes #<number>` are pushed to remote repository.
<!-- issue-management-end -->

<!-- sensitive-information-protection-begin -->
## Sensitive Information Protection

NEVER commit or stage unencrypted secrets, credentials, tokens, keys, or PII:

1. **Secret & Token Env Vars**: Place tokens, API keys, passwords, and secret env vars in `bash/.tokens.age` (deployed to `~/.tokens` mode `0600` by `enstow`), never in `bash/.bash_exports`, `bash/.bashrc`, `bash/.profile`, or plaintext configs. Edit securely via `task edit` (`enstow edit --apply bash/.tokens.age`, re-encrypts + re-deploys) or update `~/.tokens` and run `task encrypt`.
2. **Age Encryption (`enstow`)**: Encrypt sensitive files with `enstow encrypt` / `task encrypt` (`.age` suffix). Decrypt in memory via `enstow apply` or explicitly with `task decrypt`. Generate identity keys with `enstow keygen`. Plaintext secret targets belong in `$HOME` (`0600`), never inside repo working tree.
3. **Pre-Commit Guard**: Run `task check-secrets` (`enstow doctor --staged -s .`) and install hook via `task install-hooks`. Run `task doctor` (`enstow doctor`) to audit permissions, `.gitignore` gaps, and leaks.
4. **Ignore Files**: Add plaintext secret paths to `.gitignore` and package `.enstowignore` (`task create-ignore -- <package>`). Commit only `.age` files.
5. **Explicit Staging**: Never use blanket staging (`git add .` or `git add -A`) when untracked secret files exist; stage explicitly by name and inspect `rtk git diff --staged`.
<!-- sensitive-information-protection-end -->

---

## Project Overview & Stack

Personal dotfiles managed with **enstow** (symlinking + built-in `age` encryption), **Task** (`Taskfile.yaml`), and **Bash**.

- **Config & Package Registry**: Active packages, recipients, `prune = true`, and `mask_secrets = true` configured in `.enstow.toml` (auto-discovered by `enstow` from repo root).
- **Key Tasks**:
  - `task bootstrap`: Apply packages (symlinks + in-memory secret decryption), install git hooks.
  - `task install` / `task restow` / `task restow:fix` / `task unstow` (`task delete`) / `task scrub`: Manage packages via `enstow` (`restow:fix` runs `enstow apply --backup`, unfolding legacy folded links, pruning stale symlinks, and backing up conflicts to `~/.enstow-backup/<timestamp>`).
  - `task test`: Dry-run `enstow apply --dry-run --force`.
  - `task status` / `task diff` / `task doctor`: Inspect sync state (`--check` for non-zero exit), masked diffs, and secret/symlink hygiene.
  - `task test-integration`: Run Docker-based integration test (`bash tests/run.sh`).
  - `task edit` / `task encrypt` / `task decrypt`: Edit (`--apply` auto-redeploys), encrypt, or decrypt `.age` secrets via `enstow`.
  - `task check-secrets`: Run `enstow doctor --staged -s .` to verify staged files contain no plaintext secrets or credential leaks.
  - `task create-ignore -- <pkg>`: Create `.enstowignore` in package folder.

## enstow & Bash Conventions

- **enstow Packages**: Replicate target relative path under `<package>/` (e.g., `<pkg>/.config/<app>/config`) and register `"<pkg>"` in `.enstow.toml`.
- **enstow Ignore**: `.enstowignore` uses standard Git-style ignore syntax (NOT GNU Stow Perl regexes; e.g., `README.md`, `*.swp`, `.config/tmux/plugins/`).
- **Bash Configs (Aliases, Functions, Completions, Exports)**:
  - Always guard new entries for external binaries (aliases, functions, completions, hooks, evals) with `command_exists <bin>` first (e.g., `if command_exists direnv; then eval "$(direnv hook bash)"; fi`), and paths with `file_exists`, `dir_exists`, or `test -d`.
  - Functions in `bash/.bash_functions` require inline `## <description>` docstring on opening `{` line and `local` variable scoping.
  - Validate shell files with `bash -n <file>` and `shuck check <file>`.
- **README Formatting**: Include emoji shortcodes in headings (e.g., `## :gear: Config`).
