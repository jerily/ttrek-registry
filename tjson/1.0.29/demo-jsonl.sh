#!/bin/sh
set -eu
for tcl_shell in "$PROJECT_INSTALL_DIR/bin/tclsh" "$PROJECT_INSTALL_DIR"/bin/tclsh9.* "$PROJECT_INSTALL_DIR/bin/tclsh8.6"; do
    if [ -x "$tcl_shell" ]; then break; fi
done
exec "$tcl_shell" <<'TCL'
try {
    lappend auto_path [file join $::env(PROJECT_INSTALL_DIR) lib]
    package require tjson 1.0.29

    # Write two JSON Lines records, then read them back one at a time.
    set events [file tempfile path]
    try {
        fconfigure $events -translation binary
        ::tjson::jsonl_puts $events {M {event {S signup} user {N 42}}}
        ::tjson::jsonl_puts $events {M {event {S login} user {N 17}}}
        seek $events 0

        while {[::tjson::jsonl_gets -simple $events record]} {
            puts "User [dict get $record user]: [dict get $record event]"
        }
    } finally {
        close $events
        file delete $path
    }
} on error {message options} {
    puts stderr $message
    exit 1
}
TCL
