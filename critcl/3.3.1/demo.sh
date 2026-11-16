#!/bin/sh
set -eu
: "${PROJECT_INSTALL_DIR:?Run this example with ttrek run -package critcl -script demo}"
work=$(mktemp -d "${TMPDIR:-/tmp}/ttrek-critcl.XXXXXX")
trap 'rm -rf "$work"' EXIT HUP INT TERM
cat > "$work/example.tcl" <<'TCL'
lappend auto_path [file join $::env(PROJECT_INSTALL_DIR) lib]
package require critcl
critcl::cache [file join [file dirname [info script]] cache]
critcl::cproc add {int a int b} int {return a + b;}
set result [add 19 23]
if {$result != 42} {error "compiled command returned $result"}
puts "Compiled C command: add 19 23 = $result"
TCL
"$PROJECT_INSTALL_DIR/bin/tclsh8.6" "$work/example.tcl" "$@"
