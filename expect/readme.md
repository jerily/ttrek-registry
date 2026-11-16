# expect

Automate interactive command-line programs.

[Upstream](https://github.com/tcltk-depot/expect) · LicenseRef-Public-Domain

- **6.0.0-alpha.2:** latest upstream tag, [v6.0a2](https://github.com/tcltk-depot/expect/tree/v6.0a2).
  Prerelease supporting Tcl 8.6 and 9.x; no patches.
- **5.45.4:** legacy stable release for Tcl 8.6, using the original SourceForge
  archive with compiler and macOS compatibility fixes.

```sh
ttrek install expect@6.0.0-alpha.2
ttrek run -package expect -script demo
```

Requires a C compiler and make. Use `expect@5.45.4` for the stable release.
The example drives a local shell through a pseudo-terminal and checks the exact
Expect version. Rebuild existing Tcl 9 installations to install the private
headers required by Expect; updated Tcl 9 recipes include them.

The stable recipe includes [header fixes](https://github.com/Homebrew/homebrew-core/blob/master/Patches/expect/headers.diff),
the [Darwin pseudo-terminal fix](https://github.com/iains/darwin-expect/commit/2a98bd855e9bf2732ba6ddbd490b748d5668eeb0),
and the channel initializer correction from the
[LFS compiler patch](https://www.linuxfromscratch.org/patches/lfs/12.2/expect-5.45.4-gcc14-1.patch).
It also recognizes ARM64 hosts, uses C17, and fixes macOS library paths and
obsolete prebinding flags.
The configure patch is regenerated with Autoconf 2.69; users do not need Autoconf.

The upstream license places the NIST code in the public domain.

Linux: 5.45.4 passes its example and 29 upstream tests with Tcl 8.6;
6.0a2 passes its example and 32 tests with Tcl 8.6, 9.0, and 9.1.
macOS has not been tested.
