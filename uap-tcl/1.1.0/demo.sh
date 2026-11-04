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
    package require uap 1.1.0
    # Precompile patterns before handling requests; otherwise compilation is lazy.
    ::uap::init

    set agents [list \
        {Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36} \
        {Mozilla/5.0 (Linux; Android 11; SM-A225M) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/85.0.4183.127 Mobile Safari/537.36 Instabridge/22} \
        {curl/8.10.1}]
    foreach agent $agents {
        set parsed [::uap::parse $agent]
        puts "Input: [dict get $parsed string]"
        puts "  Browser: [dict get $parsed ua]"
        puts "  OS: [dict get $parsed os]"
        puts "  Device: [dict get $parsed device]"
    }
    set mobile [lindex $agents 1]
    puts "OS only: [::uap::parse $mobile os]"
    puts "Device only: [::uap::parse $mobile device]"
    puts "Unknown browser: [::uap::parse {unrecognized-client} ua]"
} on error {message options} {
    puts stderr $message
    exit 1
}
TCL
