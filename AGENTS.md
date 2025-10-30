# Gemini Guidelines

## Stow Ignore Files

Stow ignore files (`.stow-local-ignore`) use Perl regular expressions to specify which files to ignore.

!!! note
    A `.stow-local-ignore` file must be placed inside a stow package directory (e.g., `bash/`) to ignore files within that specific package.

-   **Syntax**: Each line in the file is a Perl regular expression.
-   **Comments**: Lines starting with `#` are comments.
-   **Path Matching**:
    -   If the regex contains a `/`, it is matched against the file's path relative to the package directory (e.g., `/path/to/file`).
    -   If the regex does not contain a `/`, it is matched against the file's basename (e.g., `file.txt`).

### Examples

-   `^/README.*`: Ignores files starting with `README` in the root of the package directory.
-   `\.enc$`: Ignores any file ending with `.enc`.
-   `^/bash/\.tokens\.enc$`: Ignores the specific file `.tokens.enc` in the `bash` directory.

## Handling Sensitive Information

All sensitive information, such as API keys or tokens, must be encrypted using [SOPS](https://github.com/getsops/sops).

### Encryption Workflow

1.  Place sensitive data in a file (e.g., `.env`).
2.  Encrypt the file with SOPS, giving it a `.enc` extension (e.g., `.env.enc`).
    ```shell
    sops --encrypt --input-type dotenv --output-type dotenv .env > .env.enc
    ```
3.  Add the original unencrypted file to `.gitignore` to prevent it from being committed.
4.  Commit the encrypted `.enc` file to the repository.
5.  If the sensitive file is part of a stow package, add the unencrypted file's name to the package's `.stow-local-ignore` file.

!!! warning
    Do not use in-place encryption or decryption (`-i` or `--in-place`). Always encrypt to a new file and decrypt to stdout or a new file. This prevents accidental commitment of unencrypted sensitive files.
