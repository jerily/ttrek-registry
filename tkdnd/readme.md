# tkdnd

Native drag and drop for Tk widgets.

[Upstream](https://github.com/petasis/tkdnd) · 2.9.5 · TCL

```sh
ttrek install tkdnd
ttrek run -package tkdnd -script demo
```

Requires a C compiler and make. Uses the registry’s X11 Tk on Linux and macOS. Install X11 development headers on Linux, or XQuartz on macOS; a display is needed to run the example. This recipe selects Tcl/Tk 8.6.

The example accepts files dragged into its text widget. Uses the Xdnd backend with the registry’s X11 Tk on both platforms.
