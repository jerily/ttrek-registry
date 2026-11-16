#!/bin/sh
set -eu
: "${PROJECT_INSTALL_DIR:?Run this example with ttrek run -package tclvfs -script demo}"
work=$(mktemp -d "${TMPDIR:-/tmp}/ttrek-tclvfs.XXXXXX")
trap 'rm -rf "$work"' EXIT HUP INT TERM
cat > "$work/example.tcl" <<'TCL'
lappend auto_path [file join $::env(PROJECT_INSTALL_DIR) lib]
package require vfs::zip
set root [file dirname [info script]]
set archive [file join $root example.zip]
set out [open $archive wb]
puts -nonewline $out [binary decode base64 {UEsDBBQAAAAAAJICcF0YGN2OIQAAACEAAAAJAAAAaGVsbG8udHh0SGVsbG8gZnJvbSBhIHZpcnR1YWwgZmlsZXN5c3RlbSEKUEsBAhQDFAAAAAAAkgJwXRgY3Y4hAAAAIQAAAAkAAAAAAAAAAAAAAIABAAAAAGhlbGxvLnR4dFBLBQYAAAAAAQABADcAAABIAAAAAAA=}]
close $out
set mount [file join $root mounted]
file mkdir $mount
vfs::zip::Mount $archive $mount
try {
    set in [open [file join $mount hello.txt] r]
    try {set message [read $in]} finally {close $in}
    if {$message ne "Hello from a virtual filesystem!\n"} {error "unexpected file contents"}
    puts -nonewline $message
} finally {vfs::unmount $mount}
TCL
"$PROJECT_INSTALL_DIR/bin/tclsh8.6" "$work/example.tcl" "$@"
