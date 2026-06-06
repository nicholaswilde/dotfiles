# Add Path to Environment Variable

Adds a directory path to the `$PATH` environmental variable in the `bash` stow package.

## Description

This skill automates the process of adding new directories to the `$PATH` environment variable inside `bash/.bash_exports`. It ensures the directory path is valid, checks for duplicates to prevent bloating the path, and formats the entry to use a defensive directory check (`test -d`) before exporting.

## Protocol

1. **Verify and Resolve Inputs**:
   - **Step**: Verify the directory path provided by the user. If it does not contain environment variables, verify it exists on the filesystem.
   - **Step**: Determine if the path should be prepended (higher precedence) or appended (lower precedence) to the existing `$PATH`. Default to appending.

2. **Check for Duplicates**:
   - **Step**: Read `bash/.bash_exports`.
   - **Step**: Check if the path is already exported or added to `$PATH`. If it exists, inform the user and halt.

3. **Format and Insert**:
   - **Step**: Locate the `# PATH` section inside `bash/.bash_exports`.
   - **Step**: Format the new export line using a directory check:
     * Appending: `test -d "PATH_TO_ADD" && export PATH="${PATH}:PATH_TO_ADD"`
     * Prepending: `test -d "PATH_TO_ADD" && export PATH="PATH_TO_ADD:${PATH}"`
     * (Use environment variable expansion if the path references other variables, e.g. `${HOME}/.local/bin`).
   - **Step**: Insert the line cleanly under the `# PATH` section.

4. **Verify Syntax**:
   - **Step**: Run `bash -n bash/.bash_exports` to ensure no syntax errors were introduced.
   - **Step**: Run `shuck bash/.bash_exports` and address any warnings.

5. **Commit Changes**:
   - **Step**: Stage `bash/.bash_exports`.
   - **Step**: Commit the changes using the conventional commit format: `feat(bash): Add <path> to PATH environment variable`.

## Examples

### Appending a path
```bash
test -d "${HOME}/.local/bin" && export PATH="${PATH}:${HOME}/.local/bin"
```

### Prepending a path
```bash
test -d "/home/linuxbrew/.linuxbrew/bin" && export PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"
```
