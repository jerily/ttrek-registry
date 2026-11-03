# HarfBuzz

This recipe builds the [HarfBuzz 15.0.0 text shaping library](https://github.com/harfbuzz/harfbuzz/releases/tag/15.0.0)
with FreeType integration. It installs `libharfbuzz`, headers (including
`hb-ft.h`), and `lib/pkgconfig/harfbuzz.pc`. Command-line tools, subsetting,
raster, vector, and GPU libraries are disabled.

Build prerequisites are a C++11 compiler and CMake 3.15 or newer.
The [libfreetype recipe](../libfreetype/README.md) supplies FreeType and its
headers automatically. On Debian/Ubuntu:

```sh
sudo apt install build-essential cmake pkg-config
```

Install from a ttrek project:

```sh
ttrek install -registry /path/to/ttrek-registry harfbuzz@15.0.0
```

The default build is shared. Use the project's `useFlags: ["+static"]` or
`ttrek gen-script -static` to build a static archive. This is a standalone
package; the Tk recipes use system font libraries.
