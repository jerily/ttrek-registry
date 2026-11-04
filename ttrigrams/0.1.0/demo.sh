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
    package require ttrigrams 0.1.0

    set documents {{web server} {encryption toolkit} {web client}}
    set index [::ttrigrams::create descriptions $documents]
    try {
        puts "Literal substring search for web:"
        foreach match [$index search web 0] {
            puts "  [lindex $documents [dict get $match document]]"
        }
        puts "Typo suggestions for encrytion:"
        foreach match [$index search encrytion 1] {
            set text [lindex $documents [dict get $match document]]
            puts "  $text: distance [dict get $match distance], trigrams [dict get $match shared_trigrams]/[dict get $match query_trigrams]"
        }
        puts "Short queries use literal matching: [$index search we]"
        puts "No matches: [$index search zzzzz 0]"
    } finally {
        $index destroy
    }
} on error {message options} {
    puts stderr $message
    exit 1
}
TCL
