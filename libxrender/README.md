# Xrender

Builds [libXrender 0.9.13](https://gitlab.freedesktop.org/xorg/lib/libxrender),
the X11 Render extension client library used by Xft. Requires a C compiler,
make, pkg-config, and existing X11 development files with Xorg protocol
headers (`x11`, `xproto`, and `renderproto` pkg-config metadata).

```sh
ttrek install libxrender -y
```

Installs the library, headers, and `xrender.pc`. Shared libraries are the
default; `useFlags: ["+static"]` or `ttrek gen-script -static libxrender`
selects a static archive.
