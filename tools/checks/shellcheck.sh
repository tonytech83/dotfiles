#!/usr/bin/env bash
set -euo pipefail

find "${BUILD_WORKSPACE_DIRECTORY:-.}" -type f -name "*.sh" -exec shellcheck -S warning {} \;