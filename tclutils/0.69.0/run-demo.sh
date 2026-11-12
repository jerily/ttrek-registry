#!/bin/sh
set -eu
prefix=${PROJECT_INSTALL_DIR:?Run this script through ttrek}
package_dir="$prefix/lib/tclutils-0.69.0"
demo=${1:?Usage: run-demo.sh NAME [ARGS...]}
shift
case "$demo" in
    ''|*[!a-zA-Z0-9-]*) echo "Expected a demo name such as csv or tkuaction" >&2; exit 2 ;;
esac
example="demo-$demo.tcl"
[ -f "$package_dir/examples/$example" ] || { echo "Unknown example: $example" >&2; exit 2; }
tclsh=
for candidate in "$prefix"/bin/tclsh9.* "$prefix"/bin/tclsh8.*; do
    if [ -x "$candidate" ]; then tclsh=$candidate; break; fi
done
[ -n "$tclsh" ] || { echo "No installed Tcl interpreter in $prefix/bin" >&2; exit 1; }
# Upstream demos create files beside themselves; give every run its own copy.
# Retain output so generated documents/images can be opened after the demo ends.
work=$(mktemp -d "${TMPDIR:-/tmp}/tclutils-example.XXXXXX")
cp -R "$package_dir/examples" "$work/examples"
cp "$package_dir/README.md" "$package_dir/CHANGELOG.md" "$work/"
ln -s "$package_dir/lib" "$work/lib"
ln -s "$package_dir/tools" "$work/tools"
ln -s "$package_dir/docs" "$work/docs"
printf 'Example workspace (retained): %s\n' "$work"
cd "$work"
exec "$tclsh" "$package_dir/run-demo.tcl" "$work/examples/$example" "$@"
