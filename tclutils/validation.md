# Snapshot review and validation

Reviewed on 2026-11-11 using the exact source commits recorded in the
[tclutils](README.md) and [tkutils](../tkutils/README.md) READMEs. These versions
are commit-pinned snapshots of the current branches, as requested, rather than
the projects' older version tags.

## Installation and package discovery

Built the dependency stack in an isolated prefix on Linux, including Tcl/Tk
9.1.0, Tcllib 2.0, Tklib 0.9, tDOM 0.9.6, and SQLite. Applied the final adapters
to fresh copies of the pinned archives and installed both utility packages.

With `TCLLIBPATH`, `TCLUTILS_TM`, `TKUTILS_TM`, `TCL_LIBRARY`, and `TK_LIBRARY`
unset, the installed interpreter successfully loaded:

- `tclutils` 0.69.0, `tclutils::tucsv` 0.2, and the nested
  `tclutils::tuprovider::sftp` 0.2 module;
- `tkutils` 0.49.0, `tkutils::tkutltools` 0.3, `tkutils::tkuxml` 0.1,
  `tkutils::tkusqlite` 0.1, and `tkutils::tkuscrolledframe` 0.1;
- Tablelist 7.4.1, tDOM 0.9.6, FTP 2.4.14, and SQLite, including an in-memory
  query returning 42. Tcl 9.1 also installs SQLite 3.53.4, which package
  discovery selected over the explicitly installed SQLite 3.45.3 binding.

The `check-package` scripts reproduce these load checks. They do not test live
SFTP, HTTPS, databases on remote servers, or every optional feature.

The dependency build exposed an existing `gen-script` limitation: generated
scripts use `tar -xzf`, whereas Tk 9.1's existing X11 dependencies include `.xz`
archives. The full generated build succeeded after changing that command to
`tar -xf` in the temporary test script. No X11 recipes or archive-extraction
code were changed here. Normal `ttrek install` uses its separate libarchive
unpacker. Static build scripts were generated and syntax checked; a full
static runtime build was not tested.

## Examples

All **82 selected Tcl examples** completed on Tcl 9.1. All **64 selected Tk
examples** passed startup checks with a virtual X display (Tcl 9.1 / Tk 9.0.3),
with asynchronous errors treated as failures and each root window closed by
the test driver. This checks construction and normal exit, not every button,
menu item, interactive edit, or visual detail.

The adapter fixes a demo-only Tcl 9.1 collision: `demo-task.tcl` imports its
`timer` using `namespace import -force`. The utility modules remain unchanged.
Every demo runs against installed modules from a separate writable example
copy. No per-demo shell files are needed: `ttrek.json` uses one `run-demo.sh`
with preset `args` per package.

## Upstream test suites

With the built Tcl/Tk 9.1 stack and a virtual display:

| Project | Total | Passed | Skipped | Failed |
| --- | ---: | ---: | ---: | ---: |
| tclutils | 2688 | 2652 | 35 | 1 |
| tkutils | 975 | 936 | 37 | 2 |

The failures were examined rather than ignored:

- `tufetch-3.6` tries to rename `::http::geturl` before Tcl 9.1's lazy loading
  creates it. The mock setup fails; the local HTTP redirect test succeeds.
  Both HTTP test files pass on Tcl 8.6 with local sockets permitted.
- `tkutltools-2.1` and `2.2` successfully load both package orders, returning
  `0 7.4.1`. Their assertion expects `0 ok`, but their helper tests the version
  with `string is double`, which rejects the three-component version `7.4.1`.

Skipped cases include optional TLS, font/data dependencies, platform-specific
features, and live services. These results establish useful working coverage,
not a claim that the whole upstream suite passes or that every optional feature
is production-tested. Upstream tests were not patched.

## Registry and CLI checks

The companion ttrek change accepts registry `file` references with preset
`args`, preserves the shebang, and caches the resolved script body for offline
use. Its regression checks cover generation, installation, literal argument
quoting, empty and Unicode arguments, runtime argument order, malformed input,
and running cached scripts after the registry is removed.
The `project_scripts`, `gen_script`, and `local_registry` regression suites all
passed using a Release build of the modified ttrek. Final recipe generation and
shell syntax checks passed for the Tcl/Tk 9.1 and 8.6 selections and for a static
tclutils build script.

The companion hosted-registry change resolves the same `file` and `args`
format for HTTP installs. Its handler suite passed all 65 tests, including
literal preset arguments, runtime argument order, and malformed references.

The package recipes include `tags`, pinned sources, declared dependencies,
UTF-8 script files, and shell syntax checks. The broader platform/build
requirements are described in the existing [Tk README](../tk/README.md).
