# Manage Bash Functions

Adds, modifies, or removes shell functions in the `bash/.bash_functions` file.

## Description

This skill automates the management of bash functions in `bash/.bash_functions`. It enforces repository code standards, including the mandatory inline `##` docstring on the function declaration line, scoper limits using `local` variables, and conditional wrappers to ensure functions depending on optional external commands are only defined if those commands exist.

## Protocol

1. **Verify Inputs**:
   - **Step**: Read the proposed function name, arguments, and body.
   - **Step**: Check if the name collides with existing commands, aliases, or functions.

2. **Check for Command or Directory Existence**:
   - **Step**: Identify any optional external commands or directories required by the function (e.g. `jq`, `lynx`, `kubectl`).
   - **Step**: **CRITICAL**: If the function depends on optional external tools, wrap the function definition inside a conditional block (e.g., `if command_exists <command>; then ... fi` or checking directory/file existence).

3. **Format and Document**:
   - **Step**: Format the function declaration using the standard syntax:
     ```bash
     function_name() { ## Inline description of what the function does
       # function body...
     }
     ```
   - **Step**: **CRITICAL**: The docstring `## <description>` must be present on the same line as the opening curly brace.
   - **Step**: Ensure all variables inside the function are scoped locally using `local` to prevent environment pollution.

4. **Insert/Modify**:
   - **Step**: Read `bash/.bash_functions`.
   - **Step**: Insert the new function or update the existing function in a logical place within the file (respecting existing conditional wrapper blocks if applicable).

5. **Verify Syntax & Quality**:
   - **Step**: Run `bash -n bash/.bash_functions`.
   - **Step**: Run `shellcheck bash/.bash_functions` and fix any warnings or errors.

6. **Commit Changes**:
   - **Step**: Stage `bash/.bash_functions`.
   - **Step**: Commit using conventional commit format: `feat(bash): Add function '<function_name>'`.

## Examples

### Wrapping a function depending on an optional command
```bash
if command_exists jq; then
  function getcom() { ## Get a short commit from a repo
    check_args "getcom <user/repo>" "${1}" || return 1  
    curl -s "https://api.github.com/repos/${1}/commits" | jq -r '.[0].sha' | head -c 7 && printf "\n"
  }
fi
```
