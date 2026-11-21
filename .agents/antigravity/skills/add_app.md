# /app add <path>

Adds the configuration files of a new application to this dotfiles repository and configures `enstow`.

## Description

This skill automates the process of adding an existing application's configuration file or folder to the dotfiles repository. It replicates the relative path structure under an `enstow` package directory, handles secrets encryption via `age` (if requested), updates `.enstow.toml` and `.enstowignore`, tests the dry-run simulation, and applies symlinks / decrypted secrets.

## Protocol

1. **Verify and Resolve Inputs:**
   - **Step:** Verify that the provided `<path>` exists on the filesystem. If not, stop and report: "Error: Path '<path>' does not exist."
   - **Step:** Prompt the user to provide a package name (e.g. `my_new_app`).
   - **Step:** Determine if the path is within the home directory (`~/`). Calculate the relative path from `$HOME` (e.g. `~/.config/myapp/config.toml` -> `.config/myapp/config.toml`).
     - If the path is outside the home directory, stop and ask the user to clarify.

2. **Replicate Structure and Register Package:**
   - **Step:** Use `enstow -C .enstow.toml add <path> -p <package_name>` (with `--encrypt` for secret files), or create `<workspace-root>/<package_name>/<relative_path_from_home>` and copy files.
   - **Step:** Add `"<package_name>"` to `packages` in `.enstow.toml` at the repository root.

3. **Check for Secrets:**
   - **Step:** Ask the user if the configuration files contain any sensitive information (e.g. API keys, passwords, tokens).
   - **Step:** **If the files contain secrets**:
     - Encrypt the file as `.age` using `enstow -C .enstow.toml encrypt <file> -o <package>/<relative_path>.age` (or `enstow add --encrypt`).
     - Add the plaintext file path to root `.gitignore` and (if needed) `<package_name>/.enstowignore` (Git-style ignore syntax).
     - Never commit or leave plaintext secret files in the repository working tree.
   - **Step:** **If the files do not contain secrets**:
     - Retain them as plaintext.

4. **Verify and Apply:**
   - **Step:** Run a dry-run simulation using `task test` or `enstow -C .enstow.toml apply --dry-run <package_name>`.
   - **Step:** Review simulation output. If there are conflicts or errors, report them and halt.
   - **Step:** Ask the user to confirm applying the package, then run `enstow -C .enstow.toml apply --force <package_name>` and verify with `task status` and `task doctor`.

5. **Commit Changes:**
   - **Step:** Run `task check-secrets` and stage the new package files explicitly.
   - **Step:** Commit using Conventional Commits: `feat(<package_name>): Add configuration files and enstow package`.
