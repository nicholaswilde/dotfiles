# Agent Guidelines

## Project Overview

This repository contains personal dotfiles managed with GNU Stow. The goal is to have a portable and reproducible development environment. Secrets are encrypted with SOPS.

## Key Technologies

-   **[GNU Stow](https://www.gnu.org/software/stow/)**: Manages symlinks for dotfiles.
-   **[SOPS](https://github.com/getsops/sops)**: Manages encrypted secrets.
-   **[Task](https://taskfile.dev/)**: A task runner used for automating common operations.
-   **Bash**: The primary shell environment.

## Workflows

### Installation

To bootstrap the environment, run the `bootstrap` task. This will install dependencies, decrypt secrets, and stow the dotfiles.

```shell
task bootstrap
```

### Adding a New Application's Configuration

1.  **Create a directory**: Create a new directory for the application (e.g., `newapp/`).
2.  **Replicate directory structure**: Inside the `newapp/` directory, create the path that the application expects in the home directory. For example, if the application's configuration file is at `~/.config/newapp/config.json`, you should create `newapp/.config/newapp/config.json`.
3.  **Stow the new package**: Run `task install` or `stow newapp` to create the symlinks.

### Managing Secrets

All sensitive information, such as API keys or tokens, must be encrypted using [SOPS](https://github.com/getsops/sops).

#### Encryption Workflow

1.  Place sensitive data in a file (e.g., `bash/.tokens`).
2.  Encrypt the file using the `encrypt` task:
    ```shell
    task encrypt
    ```
    This will create an encrypted file with a `.enc` extension (e.g., `bash/.tokens.enc`).
3.  Add the original unencrypted file to `.gitignore`.
4.  Commit the encrypted `.enc` file to the repository.
5.  If the sensitive file is part of a stow package, add the unencrypted file's name to the package's `.stow-local-ignore` file. Use the `create-ignore` task to create the ignore file if it doesn't exist.
    ```shell
    task create-ignore -- <package-name>
    ```

!!! warning
    Do not use in-place encryption or decryption (`-i` or `--in-place`). Always encrypt to a new file and decrypt to stdout or a new file. This prevents accidental commitment of unencrypted sensitive files.

### Git Workflow

-   **Viewing Issues**: Before starting work, check existing issues using `gh issue list` or `gh issue view <issue_number>` to understand ongoing tasks or bugs.
-   **Closing Issues via Commits**: If your commit resolves an open issue, include a closing keyword (e.g., `Closes #<issue_number>`, `Fixes #<issue_number>`, `Resolves #<issue_number>`) in your commit message body or footer. GitHub will automatically close the linked issue when the commit is merged into the default branch.

### Using Tasks

This repository uses [Task](https://taskfile.dev/) to automate common commands. The tasks are defined in `Taskfile.yaml`.

To list all available tasks, run the default task:

```shell
task
```

Key tasks include:
-   `task bootstrap`: Sets up the entire environment.
-   `task install`: Stows all packages.
-   `task update`: Pulls changes from the repository and applies them.
-   `task encrypt`/`task decrypt`: Manages secrets.
-   `task test`: Performs a dry run of the stowing process.

## Development Guidelines

### Bash Functions

When adding a new function to `bash/.bash_functions`, a docstring should be added to the same line as the function declaration. The docstring should be placed after the opening curly brace and start with two pound signs (`##`). Refer to `bash/.bash_functions` for examples.

### Stow Ignore Files

Stow ignore files (`.stow-local-ignore`) use Perl regular expressions to specify which files to ignore.

!!! note
    A `.stow-local-ignore` file must be placed inside a stow package directory (e.g., `bash/`) to ignore files within that specific package.

-   **Syntax**: Each line in the file is a Perl regular expression.
-   **Comments**: Lines starting with `#` are comments.
-   **Path Matching**:
    -   If the regex contains a `/`, it is matched against the file's path relative to the package directory (e.g., `/path/to/file`).
    -   If the regex does not contain a `/`, it is matched against the file's basename (e.g., `file.txt`).

#### Examples

-   `^/README.*`: Ignores files starting with `README` in the root of the package directory.
-   `\.enc$`: Ignores any file ending with `.enc`.
-   `^/bash/\.tokens\.enc$`: Ignores the specific file `.tokens.enc` in the `bash` directory.
