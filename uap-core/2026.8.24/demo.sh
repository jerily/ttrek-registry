#!/bin/sh
set -eu
uap_data="$PROJECT_INSTALL_DIR/share/uap-core/regexes.yaml"
printf 'User-agent data: %s\n' "$uap_data"
# The data package contains patterns; uap-tcl provides the Tcl parser.
awk '
    /^[a-z_]+:/ { section = $1; sub(/:$/, "", section) }
    /^  - regex:/ { counts[section]++ }
    END {
        printf "Browser patterns: %d\n", counts["user_agent_parsers"]
        printf "OS patterns: %d\n", counts["os_parsers"]
        printf "Device patterns: %d\n", counts["device_parsers"]
    }
' "$uap_data"
