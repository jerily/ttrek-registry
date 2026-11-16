#!/bin/sh
set -eu
: "${PROJECT_INSTALL_DIR:?Run this example with ttrek run -package udp -script demo}"
work=$(mktemp -d "${TMPDIR:-/tmp}/ttrek-udp.XXXXXX")
trap 'rm -rf "$work"' EXIT HUP INT TERM
cat > "$work/example.tcl" <<'TCL'
lappend auto_path [file join $::env(PROJECT_INSTALL_DIR) lib]
package require udp
set receiver [udp_open 0]
fconfigure $receiver -blocking 0 -buffering none -translation binary
set sender [udp_open]
fconfigure $sender -remote [list 127.0.0.1 [fconfigure $receiver -myport]] -buffering none -translation binary
proc receive {channel} {
    set ::message [read $channel]
    set ::done 1
}
fileevent $receiver readable [list receive $receiver]
set timer [after 3000 {set ::done timeout}]
puts -nonewline $sender "hello over UDP"
vwait done
after cancel $timer
close $sender
close $receiver
if {$done eq "timeout"} {error "UDP receive timed out"}
if {$message ne "hello over UDP"} {error "unexpected datagram: $message"}
puts "Received: $message"
TCL
"$PROJECT_INSTALL_DIR/bin/tclsh8.6" "$work/example.tcl" "$@"
