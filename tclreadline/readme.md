# tclreadline

GNU Readline editing and history for Tcl shells.

[Upstream](https://github.com/flightaware/tclreadline) · 2.5.0 · BSD-3-Clause

```sh
ttrek install tclreadline
ttrek run -package tclreadline -script demo
```

Requires a C compiler and make. This recipe selects Tcl 8.6.

Uses the registry’s GNU Readline and ncurses, including on macOS. Tk integration is disabled, so the package works in console-only projects. The example starts an interactive Tcl REPL; type `exit` or press Ctrl-D to leave. Its history is temporary.
