#!/bin/sh
set -eu
for tcl_shell in "$PROJECT_INSTALL_DIR/bin/tclsh" "$PROJECT_INSTALL_DIR"/bin/tclsh9.* "$PROJECT_INSTALL_DIR/bin/tclsh8.6"; do
    if [ -x "$tcl_shell" ]; then break; fi
done
if [ ! -x "$tcl_shell" ]; then
    echo "No Tcl shell found in $PROJECT_INSTALL_DIR/bin" >&2
    exit 1
fi
exec "$tcl_shell" <<'TCL'
try {
    lappend auto_path [file join $::env(PROJECT_INSTALL_DIR) lib]
    package require topenapi 0.1.0
    set operation {{"parameters":[{"name":"page","in":"query","schema":{"type":"integer","minimum":1}}]}}
    set request [topenapi::from_twebserver {httpMethod GET queryStringParameters {page 2}}]
    puts [topenapi::validate_request $request $operation]
} on error {message options} {
    puts stderr $message
    exit 1
}
TCL
