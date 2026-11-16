#!/bin/sh
set -eu
: "${PROJECT_INSTALL_DIR:?Run this example with ttrek run -package tkcon -script demo}"
work=$(mktemp -d "${TMPDIR:-/tmp}/ttrek-tkcon.XXXXXX")
trap 'rm -rf "$work"' EXIT HUP INT TERM
cat > "$work/example.tcl" <<'TCL'
lappend auto_path [file join $::env(PROJECT_INSTALL_DIR) lib]
package require Tk
wm title . "tkcon example"
package require tkcon
wm withdraw .
tkcon show
wm protocol .tkcon WM_DELETE_WINDOW {destroy .}
puts "Try: expr {6 * 7}"

bind . <Escape> {destroy .}
if {$argv eq {--smoke}} {after 250 {destroy .}}
tkwait window .
TCL
"$PROJECT_INSTALL_DIR/bin/tclsh8.6" "$work/example.tcl" "$@"
