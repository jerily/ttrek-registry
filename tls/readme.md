# tls

TLS channels for Tcl, backed by OpenSSL.

[Upstream](https://github.com/bohagan1/TclTLS) · 2.0.1 · TCL

```sh
ttrek install tls
ttrek run -package tls -script demo
```

Requires a C compiler and make. This recipe selects Tcl 8.6.

The example reports the linked TLS library and available TLS 1.3 ciphers. Applications must configure peer verification and trusted CA certificates for their connections.
