# tclgd

`ttrek install tclgd` installs FlightAware's `tcl.gd` 1.4.0 and its GD,
PNG, JPEG, FreeType, and zlib dependencies. Load it with `package require tclgd`.
The build requires a C/C++ compiler, Make, CMake, Autoconf, and pkg-config.

Both Tcl 8.6 and Tcl 9 are supported. The upstream release contains the Tcl 9
API changes but still requests Tcl 8.1 during initialization. The recipe patches
those two version checks to use the Tcl version against which it was compiled.
Explicit Tcl header and GD configuration paths keep builds within the selected
installation prefix. Build a separate extension for each Tcl major version.

On macOS, the shared extension uses `@loader_path/..` to find GD's libraries
in the parent `lib` directory. Rebuild an existing installation after updating
the recipe with `ttrek install -y -force tclgd`.

From an initialized project using this registry:

```sh
ttrek install tclgd@1.4.0
ttrek run -package tclgd -script demo
# Choose an output filename:
ttrek run -package tclgd -script demo -- drawing.png
# Encode and decode PNG, JPEG, and GIF images:
ttrek run -package tclgd -script demo-formats -- images
```

The scripts use the recipe's `file` references. They write images in the current
working directory (or the supplied destination) and refuse to overwrite files.
`demo` draws shapes and writes a PNG through a Tcl channel. `demo-formats` uses
byte arrays to encode and decode all three formats and checks image dimensions.

The GD dependency enables PNG, JPEG, GIF, WBMP, legacy GD/GD2, and FreeType
rendering. Optional TIFF, WebP, HEIF, AVIF, XPM, fontconfig, and RAQM support is
not enabled. `libjpeg-turbo` supplies the libjpeg API; its separate TurboJPEG API,
command-line tools, and upstream test programs are not installed.

Shared libraries are the default. With `+static`, the libraries and Tcl
extension are archives for embedding; the application must register
`Tclgd_Init` and link GD and its dependencies. The example scripts require the
shared extension.
