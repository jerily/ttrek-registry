#!/bin/sh
set -eu
if [ -z "${TCLSH:-}" ]; then
    for interpreter in tclsh9.1 tclsh9.0 tclsh8.6 tclsh; do
        if command -v "$interpreter" >/dev/null 2>&1; then TCLSH=$interpreter; break; fi
    done
fi
exec "${TCLSH:-tclsh}" <<'TCL'
package require treqmon 2.2.0
::treqmon::init_middleware {store {tsvstore {history_max_events 100}}}
set router [::tpathexp::router]
::treqmon::mount $router
$router add GET /hello {apply {{request context params} {
    dict create statusCode 200 headers {} body hello
}}}
set response [$router dispatch {method GET path /hello}]
puts "Hello: HTTP [dict get $response statusCode]"
puts "Recorded requests: [llength [::treqmon::get_history_events]]"
set response [$router dispatch {method GET path /request-monitor}]
puts "Monitor: HTTP [dict get $response statusCode]"
$router destroy
TCL
