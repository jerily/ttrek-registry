# Tklib

Tklib 0.9 supplies reusable Tcl/Tk GUI packages, including Tablelist 7.4.1 and
Scrollutil 2.4. This recipe uses the upstream
[`tklib-0.9` tag](https://github.com/tcltk/tklib/tree/tklib-0.9), represented as
registry version `0.9.0`.

It installs the Tcl libraries with upstream's `install-libraries` target and
depends on Tk and Tcllib. GUI use needs a display. The tkutils recipe uses it for
Tablelist widgets and scrollable frames. Tcl discovers these packages normally:

```tcl
package require tablelist_tile
package require scrollutil
```

Load one Tablelist variant per interpreter: applications using tkutils should
use the themed `tablelist_tile` variant rather than mixing it with classic
`tablelist`.
