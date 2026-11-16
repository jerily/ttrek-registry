#!/bin/sh
set -eu
: "${PROJECT_INSTALL_DIR:?Run this example with ttrek run -package tkimg -script demo}"
work=$(mktemp -d "${TMPDIR:-/tmp}/ttrek-tkimg.XXXXXX")
trap 'rm -rf "$work"' EXIT HUP INT TERM
cat > "$work/example.tcl" <<'TCL'
lappend auto_path [file join $::env(PROJECT_INSTALL_DIR) lib]
package require Tk
wm title . "tkimg example"
package require Img
set original [image create photo -width 120 -height 80]
$original put steelblue -to 0 0 120 80
$original put gold -to 20 20 100 60
set filename [file join [file dirname [info script]] sample.tiff]
$original write $filename -format tiff
set copy [image create photo -file $filename -format tiff]
if {[$copy get 30 30] ne [$original get 30 30]} {error "TIFF round-trip failed"}
label .image -image $copy
pack .image -padx 20 -pady 20
puts "TIFF round-trip succeeded."

bind . <Escape> {destroy .}
if {$argv eq {--smoke}} {after 250 {destroy .}}
tkwait window .
TCL
"$PROJECT_INSTALL_DIR/bin/tclsh8.6" "$work/example.tcl" "$@"
