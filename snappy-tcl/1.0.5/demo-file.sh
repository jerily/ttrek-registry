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
    package require snappy 1.0.5
    set paths {}
    try {
        # Each channel owns a fresh temporary file; no existing files are replaced.
        set bytes [binary decode hex [string repeat 0001027f80feff 1000]]
        foreach kind {input compressed restored} {
            set channel [file tempfile path]
            lappend paths $path
            try {
                fconfigure $channel -translation binary
                switch $kind {
                    input {puts -nonewline $channel $bytes}
                    compressed {puts -nonewline $channel [snappy::compress $bytes]}
                    restored {puts -nonewline $channel [snappy::uncompress $bytes]}
                }
                seek $channel 0
                set bytes [read $channel]
                puts "$kind file: [file size $path] bytes"
            } finally {
                close $channel
            }
        }
        if {[binary encode hex $bytes] ne [string repeat 0001027f80feff 1000]} {
            error "File round trip failed"
        }
        puts "Binary file round trip: OK"
    } finally {
        foreach path $paths {file delete $path}
    }
} on error {message options} {
    puts stderr $message
    exit 1
}
TCL
