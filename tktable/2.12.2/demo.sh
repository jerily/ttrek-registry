#!/bin/sh
set -eu
: "${PROJECT_INSTALL_DIR:?Run this example with ttrek run -package tktable -script demo}"
work=$(mktemp -d "${TMPDIR:-/tmp}/ttrek-tktable.XXXXXX")
trap 'rm -rf "$work"' EXIT HUP INT TERM
cat > "$work/example.tcl" <<'TCL'
lappend auto_path [file join $::env(PROJECT_INSTALL_DIR) lib]
package require Tk
wm title . "tktable example"
package require Tktable
array set cells {0,0 Language 0,1 Creator 1,0 Tcl 1,1 {John Ousterhout} 2,0 Python 2,1 {Guido van Rossum}}
table .table -rows 3 -cols 2 -titlerows 1 -variable cells -width 40 -height 3
pack .table -fill both -expand 1 -padx 12 -pady 12

bind . <Escape> {destroy .}
if {$argv eq {--smoke}} {after 250 {destroy .}}
tkwait window .
TCL
"$PROJECT_INSTALL_DIR/bin/tclsh8.6" "$work/example.tcl" "$@"
