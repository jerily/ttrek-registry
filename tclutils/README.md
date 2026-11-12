# tclutils

Pure-Tcl utilities for text, data formats, archives, documents, diagrams, and
filesystem tasks. The recipe installs upstream modules, documentation, command
line frontends, and examples under `lib/tclutils-0.69.0`.

## Source and scope

Version **0.69.0** is the version declared by the latest upstream snapshot
reviewed on 2026-11-11:
[`9718efd68f9255752e940ca869262e9be85750c3`](https://github.com/gregnix/tclutils/commit/9718efd68f9255752e940ca869262e9be85750c3)
(2026-11-02). The recipe downloads that full commit hash. This is a pinned
snapshot, not a GitHub Release. The older `v0.41.0` tag is not used.

The project is MIT licensed. Its own apps, CLI tools, test suite, examples, and
companion tkutils provide evidence of use, but not evidence of broad independent
production adoption. Both repositories were first published in June 2026; at
review time tclutils had 2 GitHub stars and no forks. Treat the many small
parsers/formatters as the documented subsets they implement, not as complete
GNU utilities, CommonMark, PDF, or office-format implementations. See upstream's
[module status](https://github.com/gregnix/tclutils/blob/9718efd68f9255752e940ca869262e9be85750c3/docs/guide/module-status.md).

## Install and load

From a project initialized with `ttrek init -y`:

```sh
ttrek install -registry /path/to/ttrek-registry tclutils@0.69.0 -y
ttrek run -package tclutils -script check-package
```

Applications can use ordinary Tcl package loading with the installed interpreter:

```tcl
package require tclutils
package require tclutils::tucsv
package require tclutils::tuprovider::sftp
```

The installation adapter supplies `pkgIndex.tcl` for all `.tm` modules, including
nested providers. Applications do not need `tcl::tm::path add`, `TCLUTILS_TM`, or
`TCLLIBPATH` when using the environment's Tcl interpreter. Requiring the SFTP
module does not establish a connection or verify that an SFTP client is present.

## Dependencies

The recipe installs Tcl (8.6.18 or 9.x), Tcllib, and the SQLite Tcl binding.
Tcl supplies `http`, TclOO, and the `zlib` command; Tcllib supplies `ftp`.
SQLite helpers use the `sqlite3` package directly, not `tdbc::sqlite3`.
Tk is not required by this recipe.

Additional features still have optional requirements that this recipe does not
install:

| Feature | Additional requirement |
| --- | --- |
| Native HTTPS, WebDAV, HTTPS service clients | Tcl `tls` and trusted CA certificates; `tufetch` can instead use an installed `curl`/`wget` |
| SFTP provider | OpenSSH `sftp`, a reachable server, and credentials |
| TDBC helper | A separately installed TDBC driver and database |
| Task thread pools | Tcl `Thread` package |
| PNG text using a font map | `Glyphs` and the requested font data; default bitmap text works without it |
| Opening files/URLs, desktop/system integration | Platform programs such as `xdg-open`, `open`, or Windows commands; some Windows features can use `twapi` |
| MMDB lookups | An application-supplied MMDB database file |

The umbrella loads without these optional dependencies. Loading a module does
not imply that every optional operation it offers can run. Network services,
credentials, TLS certificates, viewers, and desktop programs are not supplied
by either utility project. See the pinned upstream
[dependency notes](https://github.com/gregnix/tclutils/blob/9718efd68f9255752e940ca869262e9be85750c3/README.md).

## Examples

There are **82 named demos** drawn from upstream's `examples/` directory, all
using one `run-demo.sh` with preset arguments. For example:

```sh
ttrek scripts -package tclutils ls
ttrek run -package tclutils -script demo-csv
ttrek run -package tclutils -script demo-json
ttrek run -package tclutils -script demo-tupngdraw
ttrek run -package tclutils -script demo-tudocx
ttrek run -package tclutils -script demo-task
# Or pass any upstream demo name explicitly:
ttrek run -package tclutils -script demo -- csv
```

The collection covers text processing, binary encodings, hashes, CSV/JSON/XML,
ZIP/ODF/DOCX/XLSX, calendars, notes, lists, dictionaries, providers, and graphics.
The generic command also allows demos with optional requirements; named presets
focus on examples that work with the declared dependencies.

Each invocation copies the examples to a fresh temporary directory and prints
its location. Generated documents and images remain there for inspection;
remove that directory when finished. Relative demo arguments resolve there.
Use absolute paths when passing your own input or output files. The installed
examples remain unchanged.

`install.diff` also adjusts the task demo's import to avoid a name collision
with Tcl 9.1's built-in `timer` command. It does not modify the utility modules.

See [validation.md](validation.md) for the checks and remaining upstream test
issues. Registry preset arguments need the ttrek registry-script support added
alongside these recipes.
