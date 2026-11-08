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
    package require ksuid 1.0.4

    set id [::ksuid::generate_ksuid]
    set parts [::ksuid::ksuid_to_parts $id]
    puts "Generated KSUID: $id"
    puts "Length: [string length $id]"
    puts "Parts: $parts"
    # KSUID timestamps count seconds since 1400000000 (the KSUID epoch).
    set unixTime [expr {1400000000 + [dict get $parts timestamp]}]
    puts "Created (UTC): [clock format $unixTime -gmt 1 -format {%Y-%m-%d %H:%M:%S}]"
    puts "Parts round trip: [expr {$id eq [::ksuid::parts_to_ksuid $parts]}]"

    set next [::ksuid::next_ksuid $id]
    puts "Next: $next"
    puts "Previous of next: [::ksuid::prev_ksuid $next]"
    set payload [::ksuid::hex_decode [dict get $parts payload]]
    puts "Payload bytes: [string length $payload]"
    puts "Payload hex round trip: [::ksuid::hex_encode $payload]"

    # Same payload, increasing timestamps: lexical order follows time.
    set earlier [::ksuid::parts_to_ksuid [dict create timestamp 1 payload [string repeat 0 32]]]
    set later [::ksuid::parts_to_ksuid [dict create timestamp 2 payload [string repeat 0 32]]]
    puts "Sorted IDs (earlier first): [lsort [list $later $earlier]]"
} on error {message options} {
    puts stderr $message
    exit 1
}
TCL
