#!/bin/sh
set -eu
: "${PROJECT_INSTALL_DIR:?Run this example with ttrek run -package tkhtml -script demo}"
work=$(mktemp -d "${TMPDIR:-/tmp}/ttrek-tkhtml.XXXXXX")
trap 'rm -rf "$work"' EXIT HUP INT TERM
cat > "$work/example.tcl" <<'TCL'
lappend auto_path [file join $::env(PROJECT_INSTALL_DIR) lib]
package require Tk
wm title . "tkhtml example"
package require Tkhtml 3.0
html .page
.page parse {<html><body style="background:#f5f7fb;color:#20304a"><h1>Hello from Tkhtml</h1><p>Tcl renders <b>HTML</b> and <i>CSS</i>.</p></body></html>}
pack .page -fill both -expand 1
wm geometry . 520x240

bind . <Escape> {destroy .}
if {$argv eq {--smoke}} {after 250 {destroy .}}
tkwait window .
TCL
"$PROJECT_INSTALL_DIR/bin/tclsh8.6" "$work/example.tcl" "$@"
