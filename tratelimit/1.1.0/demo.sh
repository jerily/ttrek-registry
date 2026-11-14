#!/bin/sh
set -eu
if [ -z "${TCLSH:-}" ]; then
    for interpreter in tclsh9.1 tclsh9.0 tclsh8.6 tclsh; do
        if command -v "$interpreter" >/dev/null 2>&1; then TCLSH=$interpreter; break; fi
    done
fi
exec "${TCLSH:-tclsh}" <<'TCL'
package require tratelimit 1.1.0

# A tiny in-memory store for this demo; production can use valkeystore.
namespace eval ::tratelimit::middleware::demo {
    variable counts {}
    proc init {config} {variable counts; set counts {}}
    proc get_requests_made {key start end} {
        variable counts
        if {[dict exists $counts $key]} {return [dict get $counts $key]}
        return 0
    }
    proc add_request {key start now} {variable counts; dict incr counts $key}
}
::tratelimit::init_middleware {
    store {demo {}}
    global_limits {}
    route_limits {hello {by_ip {window_millis 60000 limit 2}}}
}
set router [::tpathexp::router]
::tratelimit::mount $router
$router add GET /hello {apply {{request context params} {
    dict create statusCode 200 headers {} body hello
}}} -enter_proc {::tratelimit::middleware::enter_route hello}
for {set i 1} {$i <= 3} {incr i} {
    set response [$router dispatch {method GET path /hello} {addr 127.0.0.1}]
    puts "Request $i: HTTP [dict get $response statusCode]"
}
$router destroy
TCL
