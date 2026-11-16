#!/bin/sh
set -eu
: "${PROJECT_INSTALL_DIR:?Run this example with ttrek run -package tkdnd -script demo}"
work=$(mktemp -d "${TMPDIR:-/tmp}/ttrek-tkdnd.XXXXXX")
trap 'rm -rf "$work"' EXIT HUP INT TERM
cat > "$work/example.tcl" <<'TCL'
lappend auto_path [file join $::env(PROJECT_INSTALL_DIR) lib]
package require Tk
wm title . "tkdnd example"
package require tkdnd
label .label -text "Drop files below"
text .files -width 60 -height 10
tkdnd::drop_target register .files DND_Files
bind .files <<Drop:DND_Files>> {
    foreach filename %D {.files insert end "$filename\n"}
    set result copy
}
pack .label -pady 10
pack .files -fill both -expand 1

bind . <Escape> {destroy .}
if {$argv eq {--smoke}} {after 250 {destroy .}}
tkwait window .
TCL
"$PROJECT_INSTALL_DIR/bin/tclsh8.6" "$work/example.tcl" "$@"
