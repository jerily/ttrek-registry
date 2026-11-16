# tclcurl

Tcl bindings to libcurl for URL transfers.

[Upstream](https://github.com/flightaware/tclcurl-fa) · 7.23.0 · TCL

```sh
ttrek install tclcurl
ttrek run -package tclcurl -script demo
```

Requires a C compiler and make. This recipe selects Tcl 8.6.

Packages FlightAware’s TclCurl fork. The example transfers a local file with libcurl and checks its contents, without network access.
