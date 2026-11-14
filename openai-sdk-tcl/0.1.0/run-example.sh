#!/bin/sh
# /**
#  * Copyright Jerily LTD. All Rights Reserved.
#  * SPDX-FileCopyrightText: 2026 Neofytos Dimitriou (neo@jerily.cy)
#  * SPDX-License-Identifier: MIT.
#  */

set -eu
if [ -z "${TCLSH:-}" ] && [ -n "${PROJECT_INSTALL_DIR:-}" ]; then
    for interpreter in "$PROJECT_INSTALL_DIR"/bin/tclsh "$PROJECT_INSTALL_DIR"/bin/tclsh9.* "$PROJECT_INSTALL_DIR"/bin/tclsh8.6; do
        if [ -x "$interpreter" ]; then TCLSH=$interpreter; break; fi
    done
fi
exec "${TCLSH:-tclsh}" /dev/stdin "$@" <<'TCL'
proc printDelta {event} {
    if {[dict get $event type] eq "response.output_text.delta"} {
        puts -nonewline [dict get $event delta]
        flush stdout
    }
}
proc completed {request} {set ::finished 1}

proc main {argv} {
    set modes {responses chat-completions stream-responses stream-chat-completions async-responses}
    set mode [lindex $argv 0]
    if {[llength $argv] ni {1 2} || $mode ni $modes} {
        error "Usage: run-example.sh ([join $modes |]) ?prompt?"
    }
    foreach name {OPENAI_API_KEY OPENAI_MODEL} {
        if {![info exists ::env($name)] || $::env($name) eq ""} {
            error "Set $name before running this example"
        }
    }
    if {[info exists ::env(PROJECT_INSTALL_DIR)]} {
        lappend ::auto_path [file join $::env(PROJECT_INSTALL_DIR) lib]
    }
    package require openai 0.1
    set options {}
    if {[info exists ::env(OPENAI_BASE_URL)] && $::env(OPENAI_BASE_URL) ne ""} {
        lappend options -base_url $::env(OPENAI_BASE_URL)
    }
    set prompt "Explain Tcl's event loop in three sentences."
    if {[llength $argv] == 2} {set prompt [lindex $argv 1]}
    set client [::openai::Client new {*}$options]
    try {
        set arguments [list -model $::env(OPENAI_MODEL)]
        if {$mode in {chat-completions stream-chat-completions}} {
            set method chat_completions
            lappend arguments -messages [list [dict create role user content $prompt]]
        } else {
            set method responses
            lappend arguments -input $prompt
        }
        set streaming [expr {$mode in {stream-responses stream-chat-completions async-responses}}]
        if {$streaming} {lappend arguments -stream true -on_event printDelta}
        if {$mode eq "async-responses"} {
            set ::finished 0
            set request [$client $method {*}$arguments -async true -on_done completed]
            try {
                # The application can process other Tcl events while this request runs.
                vwait ::finished
                set response [$request result]
            } finally {
                $request destroy
            }
        } else {
            set response [$client $method {*}$arguments]
        }
        if {$streaming} {
            puts ""
        } else {
            puts [::openai::output_text $response]
        }
        puts stderr "Usage: [::openai::token_usage $response]"
    } finally {
        $client destroy
    }
}
if {[catch {main $argv} message]} {
    puts stderr "Error: $message"
    exit 1
}
TCL
