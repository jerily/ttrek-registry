#!/bin/sh
set -eu
for tcl_shell in "$PROJECT_INSTALL_DIR/bin/tclsh" "$PROJECT_INSTALL_DIR"/bin/tclsh9.* "$PROJECT_INSTALL_DIR/bin/tclsh8.6"; do
    if [ -x "$tcl_shell" ]; then break; fi
done
if [ ! -x "$tcl_shell" ]; then
    echo "No Tcl shell found in $PROJECT_INSTALL_DIR/bin" >&2
    exit 1
fi
exec "$tcl_shell" <<'TCL'
try {
    lappend auto_path [file join $::env(PROJECT_INSTALL_DIR) lib]
    package require ttrie 0.1.1

    set trie [::ttrie::create names {tcl tclx tk}]
    try {
        puts "Exact lookup for tcl: [$trie contains tcl]"
        puts "Exact search: [$trie search tcl 0]"
        $trie insert tjson
        puts "Inserted tjson: [$trie contains tjson]"
        puts "Within one edit of tcl: [$trie search tcl 1]"
        puts "Within two edits of tcl (distance, then name):"
        foreach match [$trie search tcl 2] {
            puts "  [dict get $match name]: distance [dict get $match distance]"
        }
        puts "Missing key: [$trie contains missing]"
    } finally {
        $trie destroy
    }
} on error {message options} {
    puts stderr $message
    exit 1
}
TCL
