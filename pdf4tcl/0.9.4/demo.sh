#!/bin/sh
set -eu
: "${PROJECT_INSTALL_DIR:?Run this example with ttrek run -package pdf4tcl -script demo}"
work=$(mktemp -d "${TMPDIR:-/tmp}/ttrek-pdf4tcl.XXXXXX")
trap 'rm -rf "$work"' EXIT HUP INT TERM
cat > "$work/example.tcl" <<'TCL'
lappend auto_path [file join $::env(PROJECT_INSTALL_DIR) lib]
package require pdf4tcl
set channel [file tempfile filename ttrek-example.pdf]
close $channel
pdf4tcl::new pdf -paper a4 -compress 0
try {
    pdf startPage
    pdf setFont 20 Helvetica
    pdf text "Hello from Tcl" -x 50 -y 70
    pdf setFont 12 Helvetica
    pdf text "This PDF was generated with pdf4tcl." -x 50 -y 100
    pdf endPage
    pdf write -file $filename
} finally {pdf destroy}
puts "Created $filename"
TCL
"$PROJECT_INSTALL_DIR/bin/tclsh8.6" "$work/example.tcl" "$@"
