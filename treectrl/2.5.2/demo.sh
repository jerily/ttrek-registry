#!/bin/sh
set -eu
: "${PROJECT_INSTALL_DIR:?Run this example with ttrek run -package treectrl -script demo}"
work=$(mktemp -d "${TMPDIR:-/tmp}/ttrek-treectrl.XXXXXX")
trap 'rm -rf "$work"' EXIT HUP INT TERM
cat > "$work/example.tcl" <<'TCL'
lappend auto_path [file join $::env(PROJECT_INSTALL_DIR) lib]
package require Tk
wm title . "treectrl example"
package require treectrl
treectrl .tree -showroot no -width 400 -height 180
.tree column create -text "Language" -width 180
.tree column create -text "Category" -width 180
.tree element create text text
.tree style create cell
.tree style elements cell text
.tree style layout cell text -padx 6 -pady 4
foreach {language category} {Tcl Scripting C Compiled Python Scripting} {
    set item [.tree item create -parent root]
    .tree item style set $item 0 cell 1 cell
    .tree item text $item 0 $language 1 $category
}
pack .tree -fill both -expand 1

bind . <Escape> {destroy .}
if {$argv eq {--smoke}} {after 250 {destroy .}}
tkwait window .
TCL
"$PROJECT_INSTALL_DIR/bin/tclsh8.6" "$work/example.tcl" "$@"
