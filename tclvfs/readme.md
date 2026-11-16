# tclvfs

Virtual filesystems implemented in Tcl.

[Upstream](https://core.tcl-lang.org/tclvfs/) · 1.4.2 · TCL

```sh
ttrek install tclvfs
ttrek run -package tclvfs -script demo
```

Requires a C compiler and make. This recipe selects Tcl 8.6.

Pins Debian’s upstream source snapshot from 2023-09-06, together with its matching tclconfig archive. The example mounts and reads a local ZIP archive.
