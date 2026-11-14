#!/bin/sh
set -eu
for tcl_shell in "$PROJECT_INSTALL_DIR/bin/tclsh" "$PROJECT_INSTALL_DIR"/bin/tclsh9.* "$PROJECT_INSTALL_DIR/bin/tclsh8.6"; do
    if [ -x "$tcl_shell" ]; then break; fi
done
if [ ! -x "$tcl_shell" ]; then
    echo "No Tcl shell found in $PROJECT_INSTALL_DIR/bin" >&2
    exit 1
fi
export TCLGD_DEMO_OUTPUT="${1:-tclgd-demo.png}"
exec "$tcl_shell" <<'TCL'
try {
    lappend auto_path [file join $::env(PROJECT_INSTALL_DIR) lib]
    package require tclgd 1.4.0
    set image [GD create_truecolor #auto 480 240]
    try {
        set background [$image allocate_color 243 247 252]
        set blue [$image allocate_color 38 91 175]
        set green [$image allocate_color 37 145 104]
        set orange [$image allocate_color 236 151 47]
        $image filled_rectangle 0 0 479 239 $background
        for {set x 20} {$x < 480} {incr x 20} {$image line $x 0 $x 239 0xe0e7ef}
        $image filled_rectangle 40 90 130 200 $blue
        $image filled_ellipse 240 130 140 140 $green
        $image polygon filled {340 200 400 40 460 200} $orange
        set output [open $::env(TCLGD_DEMO_OUTPUT) {WRONLY CREAT EXCL}]
        try {
            fconfigure $output -translation binary
            $image write_png $output -1
        } finally {close $output}
        puts "Wrote [file normalize $::env(TCLGD_DEMO_OUTPUT)] (480 x 240 PNG)"
        puts "Tcl [info patchlevel], tclgd [package require tclgd], GD [GD version]"
    } finally {rename $image {}}
} on error {message options} {
    puts stderr $message
    exit 1
}
TCL
