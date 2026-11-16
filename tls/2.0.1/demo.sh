#!/bin/sh
set -eu
: "${PROJECT_INSTALL_DIR:?Run this example with ttrek run -package tls -script demo}"
work=$(mktemp -d "${TMPDIR:-/tmp}/ttrek-tls.XXXXXX")
trap 'rm -rf "$work"' EXIT HUP INT TERM
cat > "$work/example.tcl" <<'TCL'
lappend auto_path [file join $::env(PROJECT_INSTALL_DIR) lib]
package require tls
puts "TclTLS [package provide tls]: [tls::version]"
puts "Supported protocols: [tls::protocols]"
puts "TLS 1.3 ciphers: [tls::ciphers tls1.3 false true]"
TCL
"$PROJECT_INSTALL_DIR/bin/tclsh8.6" "$work/example.tcl" "$@"
