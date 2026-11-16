#!/bin/sh
set -eu
: "${PROJECT_INSTALL_DIR:?Run this example with ttrek run -package tclreadline -script demo}"
work=$(mktemp -d "${TMPDIR:-/tmp}/ttrek-tclreadline.XXXXXX")
trap 'rm -rf "$work"' EXIT HUP INT TERM
cat > "$work/example.tcl" <<'TCL'
lappend auto_path [file join $::env(PROJECT_INSTALL_DIR) lib]
package require tclreadline
set history [file join [file dirname [info script]] history]
if {$argv eq {--smoke}} {
    tclreadline::readline initialize $history
    tclreadline::readline add {expr {6 * 7}}
    tclreadline::readline write $history
    puts "Readline initialized and saved history."
} else {
    puts "Tcl Readline shell; type exit or press Ctrl-D to leave."
    tclreadline::Loop $history
}
TCL
"$PROJECT_INSTALL_DIR/bin/tclsh8.6" "$work/example.tcl" "$@"
