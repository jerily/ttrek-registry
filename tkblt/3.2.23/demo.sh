#!/bin/sh
set -eu
: "${PROJECT_INSTALL_DIR:?Run this example with ttrek run -package tkblt -script demo}"
work=$(mktemp -d "${TMPDIR:-/tmp}/ttrek-tkblt.XXXXXX")
trap 'rm -rf "$work"' EXIT HUP INT TERM
cat > "$work/example.tcl" <<'TCL'
lappend auto_path [file join $::env(PROJECT_INSTALL_DIR) lib]
package require Tk
wm title . "tkblt example"
package require tkblt
blt::graph .plot -title "Squares"
.plot element create squares -xdata {0 1 2 3 4 5} -ydata {0 1 4 9 16 25} -color steelblue
pack .plot -fill both -expand 1

bind . <Escape> {destroy .}
if {$argv eq {--smoke}} {after 250 {destroy .}}
tkwait window .
TCL
"$PROJECT_INSTALL_DIR/bin/tclsh8.6" "$work/example.tcl" "$@"
