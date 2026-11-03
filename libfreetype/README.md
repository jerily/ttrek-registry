# FreeType

`libfreetype@2.15.0` builds the [FreeType font library](https://freetype.org/)
and installs its headers, CMake configuration, and `lib/pkgconfig/freetype2.pc`.
It requires a C compiler and CMake 3.15 or newer. The registry supplies zlib;
no system FreeType development package is needed.

From a ttrek project:

```sh
ttrek install -registry /path/to/ttrek-registry libfreetype@2.15.0
```

The default build is shared; `useFlags: ["+static"]` or
`ttrek gen-script -static` builds a static archive.

Fontconfig, Xft, and HarfBuzz recipes depend on this package. FreeType's
optional HarfBuzz auto-hinting integration is disabled to avoid a dependency
cycle. Optional
bzip2-compressed fonts, PNG-compressed bitmap glyphs, Brotli/WOFF2 fonts, and
Apple HVF fonts are also disabled; ordinary TrueType/OpenType fonts and zlib
compression are supported.
