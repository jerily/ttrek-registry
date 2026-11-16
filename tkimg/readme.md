# tkimg

Additional photo image formats for Tk.

[Upstream](https://tkimg.sourceforge.net/) · 2.1.2 · TCL AND Zlib AND libpng-2.0 AND IJG AND libtiff

```sh
ttrek install tkimg
ttrek run -package tkimg -script demo
```

Requires a C compiler and make. Uses the registry’s X11 Tk on Linux and macOS. Install X11 development headers on Linux, or XQuartz on macOS; a display is needed to run the example. This recipe selects Tcl/Tk 8.6.

Includes upstream’s Tcl-stubs builds of zlib, libpng, libjpeg and libtiff, which are required by Img and cannot be replaced by ordinary shared libraries. Installs the libraries without generating upstream documentation. The example round-trips a TIFF image in a temporary directory.
