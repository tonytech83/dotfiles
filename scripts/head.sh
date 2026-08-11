#!/usr/bin/env bash

##################################################################################
##### Head
##################################################################################
head() {
    echo ""
    echo ""

    # Define and format output using printf to control line width (80 characters)
    if [ -f /etc/os-release ]; then
        # shellcheck source=/dev/null
        . /etc/os-release
        os_name="${ID^}"          # e.g. "Ubuntu" or "Debian"
        desc="${PRETTY_NAME}"     # e.g. "Debian GNU/Linux 12 (bookworm)"
        version="${VERSION_ID}"   # e.g. "12"
        codename="${VERSION_CODENAME}" # e.g. "bookworm"
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