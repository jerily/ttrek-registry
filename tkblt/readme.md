# tkblt

BLT-derived graph, barchart and vector commands for Tk.

[Upstream](https://github.com/wjoye/tkblt) · 3.2.23 · MIT

```sh
ttrek install tkblt
ttrek run -package tkblt -script demo
```

Requires a C compiler and make. Uses the registry’s X11 Tk on Linux and macOS. Install X11 development headers on Linux, or XQuartz on macOS; a display is needed to run the example. This recipe selects Tcl/Tk 8.6.

TkBLT is a maintained, smaller BLT fork; it does not provide the full BLT API. Load it with `package require tkblt`. This release advertises Tcl package version 3.2. Requires a C++ compiler.
