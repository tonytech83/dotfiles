#!/bin/sh

##################################################################################
##### Head
##################################################################################
head() {
    echo ""
    echo ""

    # Define and format output using printf to control line width (80 characters)
    if [ -f /etc/os-release ]; then
        # shellcheck source=/dev/null
        eval "$(
            . /etc/os-release
            rest="${ID#?}"
            first="${ID%"$rest"}"
            printf 'os_name=%s\n'  "\"$(printf '%s' "$first" | tr '[:lower:]' '[:upper:]')$rest\""
            printf 'desc=%s\n'     "\"$PRETTY_NAME\""
            printf 'version=%s\n'  "\"$VERSION_ID\""
            printf 'codename=%s\n' "\"$VERSION_CODENAME\""
        )"
    else
        os_name="Unknown"
        desc="Unknown"
        version="Unknown"
        codename="Unknown"
    fi

    [ -t 1 ] && clear

    cat << EOF
                     /\$\$
                    | \$\$
 /\$\$\$\$\$\$\$\$  /\$\$\$\$\$\$\$| \$\$\$\$\$\$
|____ /\$\$/ /\$\$_____/| \$\$__  \$\$      ${BOLD}${ITALIC}${YELLOW}OS Name${RC}     : $os_name
   /\$\$\$\$/ |  \$\$\$\$\$\$ | \$\$  \ \$\$      ${BOLD}${ITALIC}${YELLOW}Description${RC} : $desc
  /\$\$__/   \____  \$\$| \$\$  | \$\$      ${BOLD}${ITALIC}${YELLOW}OS Version${RC}  : $version
 /\$\$\$\$\$\$\$\$ /\$\$\$\$\$\$\$/| \$\$  | \$\$      ${BOLD}${ITALIC}${YELLOW}Code Name${RC}   : $codename
|________/|_______/ |__/  |__/
EOF
    echo ""
    echo ""
}