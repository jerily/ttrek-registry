# Expat

Builds [Expat 2.10.0](https://github.com/libexpat/libexpat/releases/tag/R_2_10_0),
the XML parser used by Fontconfig. Requires a C compiler and CMake.

```sh
ttrek install libexpat -y
```

Installs the library, headers, CMake configuration, and `expat.pc`. Tools,
examples, tests, and documentation are disabled. Shared libraries are the
default; `useFlags: ["+static"]` or `ttrek gen-script -static libexpat`
selects a static archive.
