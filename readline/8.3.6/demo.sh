#!/bin/sh
set -eu
: "${PROJECT_INSTALL_DIR:?Run with ttrek run -package readline -script demo}"
work=$(mktemp -d "${TMPDIR:-/tmp}/ttrek-readline.XXXXXX")
trap 'rm -rf "$work"' EXIT HUP INT TERM
cat > "$work/example.c" <<'C'
#include <stdio.h>
#include <readline/history.h>
int main(void) {
    using_history();
    add_history("Hello from Readline");
    puts(history_get(history_base)->line);
    clear_history();
    return 0;
}
C
${CC:-cc} -I"$PROJECT_INSTALL_DIR/include" "$work/example.c" \
    -L"$PROJECT_INSTALL_DIR/lib" -Wl,-rpath,"$PROJECT_INSTALL_DIR/lib" \
    -lreadline -lncursesw -o "$work/example"
"$work/example"
