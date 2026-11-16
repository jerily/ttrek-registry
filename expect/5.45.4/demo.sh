#!/bin/sh
set -eu
: "${PROJECT_INSTALL_DIR:?Run this example with ttrek run -package expect -script demo}"
work=$(mktemp -d "${TMPDIR:-/tmp}/ttrek-expect.XXXXXX")
trap 'rm -rf "$work"' EXIT HUP INT TERM
cat > "$work/example.tcl" <<'TCL'
lappend auto_path [file join $::env(PROJECT_INSTALL_DIR) lib]
package require -exact Expect 5.45.4
set timeout 5
log_user 0
spawn -noecho /bin/sh -c {printf 'Name: '; read name; printf 'Hello, %s\n' "$name"}
expect {
    "Name: " {}
    timeout {error "prompt timed out"}
    eof {error "child exited before prompt"}
}
send -- "Tcl\r"
expect {
    "Hello, Tcl" {}
    timeout {error "reply timed out"}
    eof {error "missing reply"}
}
expect eof
set status [wait]
if {[lindex $status 2] != 0 || [lindex $status 3] != 0} {error "child failed: $status"}
puts "Expect successfully drove an interactive shell."
TCL
"$PROJECT_INSTALL_DIR/bin/tclsh8.6" "$work/example.tcl" "$@"
