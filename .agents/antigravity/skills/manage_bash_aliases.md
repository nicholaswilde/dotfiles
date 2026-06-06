# Manage Bash Aliases

Adds, modifies, or removes aliases in the `bash/.bash_aliases` file.

## Description

This skill manages additions, modifications, and removals of shell aliases in `bash/.bash_aliases`. It ensures that aliases are only set if the target command or directory exists, preventing command-not-found errors and keeping the shell environment clean across different hosts.

## Protocol

1. **Verify Inputs**:
   - **Step**: Read the proposed alias name and command value.
   - **Step**: Check if the alias name is already a reserved system command (e.g. `rm`, `ls`) or an existing function in `bash/.bash_functions`. If so, warn the user and request confirmation.

2. **Check for Command or Directory Existence**:
   - **Step**: Identify the target command, executable, or directory referenced by the alias.
   - **Step**: **CRITICAL**: Ensure the alias is conditionally defined only if the target command or directory exists on the system. You must wrap the alias in an appropriate check (e.g., using `command_exists <cmd>`, `file_exists <file>`, `dir_exists <dir>`, or `test -d <dir>`). Do not define naked aliases for optional commands.

3. **Check for Collisions**:
   - **Step**: Read `bash/.bash_aliases`.
   - **Step**: Search for existing declarations of the alias.
     * If adding a new alias and it already exists, ask the user if they wish to overwrite it.
     * If modifying or removing, ensure it exists.

4. **Format and Insert/Modify**:
   - **Step**: Format the alias declaration inside its conditional guard wrapper.
   - **Step**: Group the alias under the correct section in the file (e.g., Git, Docker, System, Stow). If no clear section exists, add it under a "General Aliases" or appropriate section.
   - **Step**: Insert or replace the alias line cleanly.

5. **Verify Syntax**:
   - **Step**: Run `bash -n bash/.bash_aliases` to check for syntax errors.
   - **Step**: Run `shuck bash/.bash_aliases` and address any warnings.

6. **Commit Changes**:
   - **Step**: Stage `bash/.bash_aliases`.
   - **Step**: Commit using conventional commit format: `feat(bash): Add alias '<alias_name>'` or `refactor(bash): Update alias '<alias_name>'`.

## Examples

### Wrapping a single command alias using `command_exists`
```bash
command_exists lazydocker && alias ld='lazydocker'
```

### Wrapping multiple related aliases under a block
```bash
if command_exists docker; then
  alias dc='docker-compose'
  alias dr='docker restart buildx_buildkit_multiarch0'
fi
```

### Wrapping a directory-dependent alias
```bash
if dir_exists "${GIT_USER_PATH}/dotfiles"; then
  alias gpd='git -C ${GIT_USER_PATH}/dotfiles pull origin main'
fi
```
