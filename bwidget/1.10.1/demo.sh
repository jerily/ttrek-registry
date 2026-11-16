#!/bin/sh
set -eu
: "${PROJECT_INSTALL_DIR:?Run this example with ttrek run -package bwidget -script demo}"
work=$(mktemp -d "${TMPDIR:-/tmp}/ttrek-bwidget.XXXXXX")
trap 'rm -rf "$work"' EXIT HUP INT TERM
cat > "$work/example.tcl" <<'TCL'
lappend auto_path [file join $::env(PROJECT_INSTALL_DIR) lib]
package require Tk
wm title . "bwidget example"
package require BWidget
LabelFrame .group -text "Choose a language"
set frame [.group getframe]
ComboBox $frame.choice -values {Tcl Python Ruby} -textvariable language -editable 0
set language Tcl
pack $frame.choice -padx 16 -pady 16
pack .group -fill both -expand 1 -padx 12 -pady 12

bind . <Escape> {destroy .}
if {$argv eq {--smoke}} {after 250 {destroy .}}
tkwait window .
TCL
"$PROJECT_INSTALL_DIR/bin/tclsh8.6" "$work/example.tcl" "$@"
