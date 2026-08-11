#!/usr/bin/env bash

##################################################################################
#####   Function to verify a tool is available after installing
##################################################################################
verify_installed() {
    PATH="$HOME/.local/bin:/usr/local/bin:$PATH" command -v "$1" >/dev/null 2>&1
}