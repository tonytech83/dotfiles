#!/usr/bin/env bash

mapfile -t sh_files < <(find "${BUILD_WORKSPACE_DIRECTORY:-.}" -type f -name "*.sh")

echo "Checking ${#sh_files[@]} shell scripts..."

for file in "${sh_files[@]}"; do
    checkbashisms "$file"
done