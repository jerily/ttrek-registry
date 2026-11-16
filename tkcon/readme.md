# tkcon

Interactive graphical console for Tcl/Tk.

[Upstream](https://github.com/wjoye/tkcon) · 2.7.11 · TCL

```sh
ttrek install tkcon
ttrek run -package tkcon -script demo
```

Pure Tcl; no compiler needed for this package. Uses the registry’s X11 Tk on Linux and macOS. Install X11 development headers on Linux, or XQuartz on macOS; a display is needed to run the example. This recipe selects Tcl/Tk 8.6.

The upstream distribution version is 2.7.11; `package require tkcon` reports 2.7.10. The recipe corrects upstream’s package index to match.
