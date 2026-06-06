# Manage Bash Functions

Adds, modifies, or removes shell functions in the `bash/.bash_functions` file.

## Description

This skill automates the management of bash functions in `bash/.bash_functions`. It enforces repository code standards, including the mandatory inline `##` docstring on the function declaration line, and validates structure and syntax.

## Protocol

1. **Verify Inputs**:
   - **Step**: Read the proposed function name, arguments, and body.
   - **Step**: Check if the name collides with existing commands, aliases, or functions.

2. **Format and Document**:
   - **Step**: Format the function declaration using the standard syntax:
     ```bash
     function_name() { ## Inline description of what the function does
       # function body...
     }
     ```
   - **Step**: **CRITICAL**: The docstring `## <description>` must be present on the same line as the opening curly brace.
   - **Step**: Ensure all variables inside the function are scoped locally using `local` to prevent environment pollution.

3. **Insert/Modify**:
   - **Step**: Read `bash/.bash_functions`.
   - **Step**: Insert the new function or update the existing function in a logical place within the file.

4. **Verify Syntax & Quality**:
   - **Step**: Run `bash -n bash/.bash_functions`.
   - **Step**: Run `shellcheck bash/.bash_functions` and fix any warnings or errors.

5. **Commit Changes**:
   - **Step**: Stage `bash/.bash_functions`.
   - **Step**: Commit using conventional commit format: `feat(bash): Add function '<function_name>'`.
