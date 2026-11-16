#!/bin/sh
set -eu
PACKAGE_SOURCE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
export PACKAGE_SOURCE_DIR
if [ -z "${TCLSH:-}" ] && [ -n "${PROJECT_INSTALL_DIR:-}" ]; then
    TCLSH="$PROJECT_INSTALL_DIR/bin/tclsh9.1"
    if [ ! -x "$TCLSH" ]; then TCLSH="$PROJECT_INSTALL_DIR/bin/tclsh"; fi
fi
exec "${TCLSH:-tclsh9.1}" /dev/stdin "$@" <<'TCL'
# 
# Copyright Jerily LTD. All Rights Reserved.
# SPDX-FileCopyrightText: 2026 Neofytos Dimitriou (neo@jerily.cy)
# SPDX-License-Identifier: MIT.
# 

# Run one example with explicit arguments and the configured AWS credentials.
proc main {argv} {
    set usage {Usage: run-example.sh (list-buckets | list-objects bucket ?prefix? | presign bucket key)}
    if {![llength $argv] || [lindex $argv 0] in {-h --help}} {puts $usage; return}
    if {[info exists ::env(PROJECT_INSTALL_DIR)]} {lappend ::auto_path [file join $::env(PROJECT_INSTALL_DIR) lib]}
    if {[info exists ::env(PACKAGE_SOURCE_DIR)]} {
        lappend ::auto_path $::env(PACKAGE_SOURCE_DIR) [file join $::env(PACKAGE_SOURCE_DIR) .. pure-tcl-aws-core]
    }
    package require pure-tcl-aws-s3 0.1.0
    set mode [lindex $argv 0]
    set arguments [lrange $argv 1 end]
    switch -- $mode {
        list-buckets {if {[llength $arguments] != 0} {error $usage}}
        list-objects {if {[llength $arguments] < 1 || [llength $arguments] > 2} {error $usage}}
        presign {if {[llength $arguments] != 2} {error $usage}}
        default {error $usage}
    }
    set client [::aws::s3::create {}]
    try {
        switch -- $mode {
            list-buckets {
                puts [$client list_buckets]
            }
            list-objects {
                puts [$client ls {*}$arguments]
            }
            presign {
                puts [$client generate_presigned_url {*}$arguments]
            }
        }
    } finally {$client destroy}
}
if {[catch {main $argv} message]} {puts stderr $message; exit 1}
TCL
