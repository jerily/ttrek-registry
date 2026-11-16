# critcl

Compile inline C code from Tcl scripts.

[Upstream](https://github.com/andreas-kupries/critcl) · 3.3.1 · TCL

```sh
ttrek install critcl
ttrek run -package critcl -script demo
```

Requires a C compiler at build time and when running the example. This recipe selects Tcl 8.6.

The example compiles a small integer-addition command, using a temporary build cache.
