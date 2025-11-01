#!/usr/bin/env bash
################################################################################
#
# Script Name: unstow.sh
# ----------------
# This script unstows files by deleting them from the home directory.
# It iterates through each stow package directory in the current repository,
# finds all the files within that package, and removes the corresponding
# files from the home directory.
#
# For safety, the script will only print the files it would delete.
# To actually delete the files, uncomment the `rm` command below.
#
# @author Nicholas Wilde, 0xb299a622
# @date 01 November 2025
# @version 1.0.0
#
################################################################################

set -euo pipefail

# Ensure the script is run from the root of the dotfiles repository
if [[ ! -f "Taskfile.yaml" ]]; then
    echo "Please run this script from the root of the dotfiles repository."
    exit 1
fi

find_stow_packages() {
    # List directories, excluding .git and other dot-prefixed ones.
    # These directories are assumed to be stow packages.
    find . -maxdepth 1 -type d \
        ! -name '.*' \
        ! -name '.' \
        -exec basename {} \;
}

main() {
    for package in $(find_stow_packages); do
        echo "--- Processing package: ${package} ---"
        # Find all files within the package directory.
        # The path of each file inside the package corresponds to the path
        # in the home directory.
        find "${package}" -type f | while read -r file_path; do
            # Remove the package directory prefix to get the target path
            # relative to the home directory.
            # e.g., "bash/.bashrc" becomes ".bashrc"
            target_file_path="${file_path#"${package}"/}"
            home_path="${HOME}/${target_file_path}"

            if [[ -e "${home_path}" ]]; then
                echo "Deleting: ${home_path}"
                # rm "${home_path}"
            else
                echo "Skipping (not found): ${home_path}"
            fi
        done
        echo ""
    done

    echo "Script finished. To actually delete files, you need to uncomment the 'rm' line in the script."
}

main

