#!/bin/sh
set -eu
: "${PROJECT_INSTALL_DIR:?Run this example with ttrek run -package tclcurl -script demo}"
work=$(mktemp -d "${TMPDIR:-/tmp}/ttrek-tclcurl.XXXXXX")
trap 'rm -rf "$work"' EXIT HUP INT TERM
cat > "$work/example.tcl" <<'TCL'
lappend auto_path [file join $::env(PROJECT_INSTALL_DIR) lib]
package require TclCurl
set filename [file join [file dirname [info script]] payload.txt]
set out [open $filename w]
puts -nonewline $out "Hello from libcurl"
close $out
set transfer [curl::init]
try {
    $transfer configure -url "file://$filename" -bodyvar body
    $transfer perform
    if {$body ne "Hello from libcurl"} {error "unexpected transfer contents"}
    puts $body
} finally {$transfer cleanup}
TCL
"$PROJECT_INSTALL_DIR/bin/tclsh8.6" "$work/example.tcl" "$@"
