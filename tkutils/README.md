# tkutils

Tcl/Tk widgets built on tclutils: editors, forms, tables, calendars, file
browsers, and desktop helpers. This recipe pairs **tkutils 0.49.0** with
**tclutils 0.69.0**.

## Source

The recipe pins the latest upstream commit reviewed on 2026-11-11:
[`6a05777a825443883b9054954ae8f0d2a4a0c366`](https://github.com/gregnix/tkutils/commit/6a05777a825443883b9054954ae8f0d2a4a0c366)
(2026-11-08). The snapshot declares version 0.49.0; it is not a GitHub Release.
The older `v0.28.0` tag is not used. Current module names use the `tku` prefix
(e.g. `tkutils::tkucsv`), unlike the old tag's `tkcsv` names.

The source is MIT licensed. Upstream provides apps, examples and tests, but
there is limited evidence of independent adoption: the repository had no stars
or forks at review time. See the shared [review and validation](../tclutils/validation.md).

## Install and load

```sh
ttrek init -y
ttrek install -registry /path/to/ttrek-registry tkutils@0.49.0 -y
ttrek run -package tkutils -script check-package
```

From the environment's installed Tcl interpreter, with a working display:

```tcl
package require tkutils
package require tkutils::tkutablelist
package require tkutils::tkuxml
package require tkutils::tkusqlite
```

No manual module-path setup is required. The adapter installs a package index
and preserves upstream's module and example layout under `lib/tkutils-0.49.0`.
The `check-package` script starts a fresh interpreter, loads the umbrella and
several individual modules, executes an in-memory SQLite query, and exits.

## Dependencies

The recipe installs tclutils, Tk, **Tklib** (including Tablelist and Scrollutil),
**tDOM**, and the **SQLite Tcl binding**. Tcllib arrives through dependencies.
TDBC alone would not satisfy the widgets' direct `package require sqlite3`.

Tablelist is required even for `package require tkutils`: the current umbrella
loads `tkufilelist`, which requires `tkutablelist`. Treating Tablelist as entirely
optional, as some upstream wording suggests, would break umbrella loading.

The registry's Tk recipes use X11 and need the system prerequisites and a
graphical display described in [the Tk README](../tk/README.md). X11 development
files and the display server are system requirements, not Tcl modules supplied
by tkutils. Xvfb can provide the display for automated tests.

Some additional widgets or operations remain optional:

| Feature | Additional requirement not installed here |
| --- | --- |
| `tkutical`, `tkumonthcanvas` | `tical` |
| SVG icons on Tk 8.6 | `tksvg`; Tk 9 provides native SVG support |
| Extended image formats / image acceleration | `Img` / `imgtools` |
| Rich HTML preview | `tcllitehtml` |
| Template PDF preview | `pdf4tcltemplate` from `pdf4tcllib`, plus `pdf4tcl` and a PDF viewer |
| Canvas PNG export with custom font maps | `Glyphs` and font data |
| DAV and other network features | See [tclutils dependencies](../tclutils/README.md#dependencies) |

Requiring the umbrella does not require every optional package. The selected
named demos avoid dependencies outside the declared stack. Refer to the pinned
[upstream widget list](https://github.com/gregnix/tkutils/blob/6a05777a825443883b9054954ae8f0d2a4a0c366/README.md)
for feature-specific requirements.

## Examples

There are **64 named GUI demos**, all using one `run-demo.sh` with a preset
argument in `ttrek.json`:

```sh
ttrek scripts -package tkutils ls
ttrek run -package tkutils -script demo-tkuaction
ttrek run -package tkutils -script demo-tkuballoon
ttrek run -package tkutils -script demo-tkujson
ttrek run -package tkutils -script demo-tkusqlite
ttrek run -package tkutils -script demo-tkuxml
ttrek run -package tkutils -script demo-tkutlgroup
# The generic command accepts the same names:
ttrek run -package tkutils -script demo -- tkuaction
```

Close the window to finish each demo. The wrapper supplies an event loop for
examples written for `wish` and makes closing the root window terminate examples
that use `vwait forever`. Each run uses a fresh copy of the examples in a printed
temporary directory; generated files remain there for inspection. Relative demo
arguments resolve there, so use absolute paths for your own files. Registry
preset arguments need the ttrek registry-script support added alongside these
recipes.
