# tkhtml

HTML and CSS rendering widget for Tk.

[Upstream](https://github.com/olebole/tkhtml3) · 3.0.0 · BSD-3-Clause

```sh
ttrek install tkhtml
ttrek run -package tkhtml -script demo
```

Requires a C compiler and make. Uses the registry’s X11 Tk on Linux and macOS. Install X11 development headers on Linux, or XQuartz on macOS; a display is needed to run the example. This recipe selects Tcl/Tk 8.6.

Pins upstream commit `e6bf0ab04a8cf967452283be23533154c1982978`. Tcl package name: `Tkhtml`, version 3.0. The example renders a local HTML fragment. Tkhtml does not implement JavaScript.

Builds with GNU C17 because this code predates C23 function-prototype rules.
