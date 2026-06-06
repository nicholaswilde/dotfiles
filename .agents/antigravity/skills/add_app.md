# /app add <path>

Adds the configuration files of a new application to this dotfiles repository and sets up Stow.

## Description
This skill automates the process of adding an existing application's configuration file or folder to the dotfiles repository. It replicates the relative path structure under a new Stow package directory, handles secrets encryption via SOPS (if requested), updates ignore files, tests the stow simulation, and applies the stow symlinks.

## Protocol

1. **Verify and Resolve Inputs:**
   - **Step:** Verify that the provided `<path>` exists on the filesystem. If not, stop and report: "Error: Path '<path>' does not exist."
   - **Step:** Prompt the user to provide a package name for this stow package (e.g. `my_new_app`).
   - **Step:** Determine if the path is within the home directory (`~/` or `/home/nicholas/`). Calculate the relative path from the home directory.
     * Example: `/home/nicholas/.config/myapp/config.toml` -> `.config/myapp/config.toml`.
     * If the path is outside the home directory, stop and ask the user to clarify if they want to stow it.

2. **Replicate Structure and Copy Files:**
   - **Step:** Create the target stow directory structure at `<workspace-root>/<package_name>/<relative_path_from_home>`.
   - **Step:** Copy the configuration file(s) from the source path to the new stow directory structure.
   - **Step:** Append the new `<package_name>` on a new line to the centralized `.stow-packages` file at the root of the repository.

3. **Check for Secrets:**
   - **Step:** Ask the user if the configuration files contain any sensitive information (e.g. API keys, passwords, tokens).
   - **Step:** **If the files contain secrets**:
     - Add the plaintext file path(s) to the workspace's root `.gitignore` file.
     - Create a `.stow-local-ignore` file in `<workspace-root>/<package_name>/` (if it does not exist) and add the plaintext file names and `.*\.enc` to it.
     - Encrypt the file using `sops -e` and save it with the `.enc` extension (e.g. `config.toml.enc`).
     - Update `Taskfile.yaml` to add decrypt/encrypt tasks and preconditions for the new secrets.
   - **Step:** **If the files do not contain secrets**:
     - Retain them as plaintext.

4. **Verify and Stow:**
   - **Step:** Run a stow simulation test using the command `stow -n -v --adopt -t ~/ <package_name>`.
   - **Step:** Review the simulation output. If there are conflicts or errors, report them to the user and halt.
   - **Step:** If clean, ask the user to confirm applying the Stow package: "Would you like to apply the Stow symlinks for <package_name>?"
   - **Step:** Upon confirmation, run the command `stow -v --adopt -t ~/ <package_name>` and verify the symlink creation.

5. **Commit Changes:**
   - **Step:** Stage the new package directory and files.
   - **Step:** Commit the changes using the conventional commit format: `feat(<package_name>): Add configuration files and stow package`.
