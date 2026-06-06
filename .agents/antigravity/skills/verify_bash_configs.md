# Verify Bash Configs

Validates and checks quality of files within the `bash/` stow package.

## Description

This skill performs syntax validation and quality gate checks on bash dotfiles (such as `.bashrc`, `.bash_aliases`, `.bash_exports`, and `.bash_functions`). It ensures no syntactical issues exist and verifies that functions follow repository documentation guidelines.

## Protocol

1. **Verify Bash Syntax**:
   - **Step**: For each file in the `bash/` folder, run:
     `bash -n bash/<file_name>`
     If any file fails the check, report the syntax error and halt.

2. **Run shuck**:
   - **Step**: Run `shuck` on all shell script files:
     `shuck bash/.bashrc bash/.bash_aliases bash/.bash_exports bash/.bash_functions`
     Report any warnings or errors. Ensure critical/major errors are resolved before proceeding.

3. **Check Function Documentation**:
   - **Step**: Parse `bash/.bash_functions` to locate all function declarations.
   - **Step**: Verify that every function declaration line (e.g. `func_name() {`) contains the double-hash comment `##` representing its docstring on the same line.
   - **Step**: Report any undocumented functions to the user.

4. **Verify Symlinks (Optional Integration)**:
   - **Step**: If stowed, check that symlinks exist in the home directory and point correctly to the repository's files.
