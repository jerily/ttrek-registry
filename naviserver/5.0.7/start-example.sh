#!/bin/sh
set -eu

export NAVISERVER_EXAMPLE_DIR="$PROJECT_HOME/naviserver-example"
mkdir -p "$NAVISERVER_EXAMPLE_DIR/pages"
printf '%s\n' 'Hello from NaviServer!' > "$NAVISERVER_EXAMPLE_DIR/pages/index.txt"
cat > "$NAVISERVER_EXAMPLE_DIR/config.tcl" <<'TCL'
ns_section ns/servers {
    ns_param example "NaviServer example"
}
ns_section ns/server/example/fastpath {
    ns_param pagedir [file join $::env(NAVISERVER_EXAMPLE_DIR) pages]
    ns_param directoryfile index.txt
}
ns_section ns/server/example/modules {
    ns_param nssock nssock
}
ns_section ns/server/example/module/nssock {
    ns_param address 127.0.0.1
    ns_param port 8000
}
TCL

exec "$PROJECT_INSTALL_DIR/bin/nsd" -f -t "$NAVISERVER_EXAMPLE_DIR/config.tcl"
