# expect

Automate interactive command-line programs.

[Upstream](https://core.tcl-lang.org/expect/index) · LicenseRef-Public-Domain

- **5.45.4:** latest stable release, with compiler and macOS compatibility fixes.
- **6.0.0-alpha.2:** community fork's v6.0a2 prerelease
  ([source](https://github.com/tcltk-depot/expect)).

```sh
ttrek install expect@5.45.4
ttrek run -package expect -script demo
```

Requires a C compiler and make. Both recipes select Tcl 8.6.
The example drives a local shell through a pseudo-terminal; the stable example
requires exactly Expect 5.45.4.

The stable recipe includes [header fixes](https://github.com/Homebrew/homebrew-core/blob/master/Patches/expect/headers.diff),
the [Darwin pseudo-terminal fix](https://github.com/iains/darwin-expect/commit/2a98bd855e9bf2732ba6ddbd490b748d5668eeb0),
and the channel initializer correction from the
[LFS compiler patch](https://www.linuxfromscratch.org/patches/lfs/12.2/expect-5.45.4-gcc14-1.patch).
It also recognizes ARM64 hosts, uses C17, and fixes macOS library paths and
obsolete prebinding flags.
The configure patch is regenerated with Autoconf 2.69; users do not need Autoconf.

The upstream license places the NIST code in the public domain.

Stable build, example, and 29 upstream tests pass on Linux. macOS has not been tested.
