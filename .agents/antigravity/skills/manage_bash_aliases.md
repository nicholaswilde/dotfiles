# Manage Bash Aliases

Adds, modifies, or removes aliases in the `bash/.bash_aliases` file.

## Description

This skill manages additions, modifications, and removals of shell aliases in `bash/.bash_aliases`. It checks for potential collisions with existing aliases, system commands, or functions, and keeps aliases logically grouped and formatted.

## Protocol

1. **Verify Inputs**:
   - **Step**: Read the proposed alias name and command value.
   - **Step**: Check if the alias name is already a reserved system command (e.g. `rm`, `ls`) or an existing function in `bash/.bash_functions`. If so, warn the user and request confirmation.

2. **Check for Collisions**:
   - **Step**: Read `bash/.bash_aliases`.
   - **Step**: Search for existing declarations of the alias.
     * If adding a new alias and it already exists, ask the user if they wish to overwrite it.
     * If modifying or removing, ensure it exists.

3. **Format and Insert/Modify**:
   - **Step**: Format the alias declaration using standard syntax: `alias name='command'`.
   - **Step**: Group the alias under the correct section in the file (e.g., Git, Docker, System, Stow). If no clear section exists, add it under a "General Aliases" or appropriate section.
   - **Step**: Insert or replace the alias line cleanly.

4. **Verify Syntax**:
   - **Step**: Run `bash -n bash/.bash_aliases` to check for syntax errors.
   - **Step**: Run `shellcheck bash/.bash_aliases` and address any warnings.

5. **Commit Changes**:
   - **Step**: Stage `bash/.bash_aliases`.
   - **Step**: Commit using conventional commit format: `feat(bash): Add alias '<alias_name>'` or `refactor(bash): Update alias '<alias_name>'`.
