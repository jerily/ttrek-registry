#!/bin/sh
set -eu
for tcl_shell in "$PROJECT_INSTALL_DIR/bin/tclsh" "$PROJECT_INSTALL_DIR"/bin/tclsh9.* "$PROJECT_INSTALL_DIR/bin/tclsh8.6"; do
    if [ -x "$tcl_shell" ]; then break; fi
done
if [ ! -x "$tcl_shell" ]; then
    echo "No Tcl shell found in $PROJECT_INSTALL_DIR/bin" >&2
    exit 1
fi
export TCLGD_DEMO_DIR="${1:-tclgd-formats}"
exec "$tcl_shell" <<'TCL'
try {
    lappend auto_path [file join $::env(PROJECT_INSTALL_DIR) lib]
    package require tclgd 1.4.0
    file mkdir $::env(TCLGD_DEMO_DIR)
    set image [GD create_truecolor #auto 160 100]
    try {
        $image filled_rectangle 0 0 159 99 0xf3f7fc
        $image filled_ellipse 80 50 100 70 0x265baf
        foreach {format encoder decoder} {
            png {png_data -1} create_from_png_data
            jpeg {jpeg_data 90} create_from_jpeg_data
            gif gif_data create_from_gif_data
        } {
            set bytes [$image {*}$encoder]
            set copy [GD $decoder #auto $bytes]
            try {
                if {[$copy width] != 160 || [$copy height] != 100} {error "$format round trip failed"}
                set filename [file join $::env(TCLGD_DEMO_DIR) image.$format]
                set output [open $filename {WRONLY CREAT EXCL}]
                try {fconfigure $output -translation binary; puts -nonewline $output $bytes} finally {close $output}
                puts "$format: [string length $bytes] bytes; decoded [$copy width] x [$copy height]; wrote $filename"
            } finally {rename $copy {}}
        }
    } finally {rename $image {}}
} on error {message options} {
    puts stderr $message
    exit 1
}
TCL
