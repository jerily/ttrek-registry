# Xft

Builds [Xft 2.3.9](https://gitlab.freedesktop.org/xorg/lib/libxft), the X11
library for antialiased fonts. Installs `libXft`, headers, and `xft.pc`.

The registry supplies Fontconfig, FreeType, Expat, Xrender, and gperf. Building
the dependency chain requires C/C++ compilers, make, CMake, pkg-config,
Python 3, and existing X11 development files (including Xorg protocol headers).
No system font-library development packages are needed.

```sh
ttrek install libxft -y
```

Builds a shared library by default. Use `useFlags: ["+static"]` in the
project or `ttrek gen-script -static libxft` for static archives. Fontconfig
discovers installed system and user fonts; this recipe does not install fonts.
