#!/bin/sh
set -eu
for tclsh in "$PROJECT_INSTALL_DIR"/bin/tclsh9.* "$PROJECT_INSTALL_DIR"/bin/tclsh8.*; do
    [ -x "$tclsh" ] || continue
    exec "$tclsh" <<'TCL'
if {[catch {
    puts "Tcl: [info patchlevel]"
    foreach pkg {tclutils tclutils::tucsv tclutils::tuprovider::sftp sqlite3 ftp} {
        puts "$pkg: [package require $pkg]"
    }
    sqlite3 checkdb :memory:
    if {[checkdb onecolumn {SELECT 6 * 7}] != 42} {error "SQLite query failed"}
    checkdb close
} message options]} {
    puts stderr [dict get $options -errorinfo]
    exit 1
}

TCL
done
echo "No installed Tcl interpreter found" >&2
exit 1
