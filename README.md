# ttrek-registry

Package specifications and build recipes for [ttrek](https://github.com/jerily/ttrek).
This repository was extracted from `jerily/ttrek.sh`, preserving the registry's Git history.

Each package version lives at `<package>/<version>/ttrek.json`. Any patches used
by that recipe are stored beside its specification. Add new versions in separate
directories so existing versions remain available.

Store example scripts as UTF-8 files in the version's recipe directory and
reference them from the spec, for example:

```json
"scripts": {"demo": {"file": "demo.sh"}}
```

The local reader and hosted API expand file references into script bodies for
installation. Scripts remain cached for offline use. References must name a
regular file directly in the recipe directory; paths and symbolic links are
rejected. Inline script strings remain supported for existing recipes.

Every recipe includes a short, single-line `description` explaining the package.
Search indexes names and descriptions and displays the matching description.
Example packages should identify themselves as dependency-solver fixtures.

`ttrie/0.1.1` provides a static C trie and a Tcl 8.6/9.x extension for exact and
edit-distance search. Its recipe builds the loadable extension by default;
`+static` builds the Tcl wrapper for embedding. Both install `ttrie::core` for CMake.
Shared builds link only the Tcl stub archive.
`ttrigrams/0.1.0` adds a static C index and Tcl extension for substring search
and verified typo suggestions; shared builds also use Tcl stubs.

`topenapi/0.2.0` validates inline OpenAPI operation fragments and JSON schemas
through C and Tcl APIs. Its C adapter converts twebserver dictionaries and exposes
upload metadata without copying contents. Its `bind` command creates typed Tcl
variables after validation and field extraction. It uses Tcl stubs for shared builds,
supports `+static` for embedding, and depends on cJSON. Run
`ttrek run -package topenapi -script demo` for a query-validation example.

`ksuid-tcl/1.0.4` also uses Tcl stubs for shared builds and supports `+static`
for embedding. Run the examples after installing the shared packages:

```sh
ttrek run -package ksuid-tcl -script demo
ttrek run -package ttrie -script demo
ttrek run -package ttrigrams -script demo
ttrek run -package uap-tcl -script demo
ttrek run -package uap-core -script demo
```

The demos show KSUID generation and round trips, exact and fuzzy trie lookup,
substring search with verified typo suggestions, and user-agent parsing.
`uap-tcl/1.1.0` uses Tcl stubs and supports `+static`. Its `uap-core/2026.8.24`
dependency pins upstream commit `73e7340c3ed8055051607b296bf46ead7aa5f19e`
and installs the patterns and YAML tests under `share/uap-core`.
The Tcl recipe regenerates its tables from that installed data.

Both Tk recipes keep `demo-widgets.sh` beside their specs; run
`ttrek run -package tk -script demo-widgets` after installing Tk.

`snappy/1.3.1` installs a static library with position-independent code and its
CMake package. `snappy-tcl/1.0.5` links that library into a Tcl extension using
stubs, and supports `+static` for embedding. After installing the shared Tcl
package, run its Unicode, binary/corrupt-input, and temporary-file examples:

```sh
ttrek run -package snappy-tcl -script demo
ttrek run -package snappy-tcl -script demo-binary
ttrek run -package snappy-tcl -script demo-file
```

To generate a build script using this registry, run the following from a project
containing `ttrek.json`:

```sh
ttrek gen-script -registry /path/to/ttrek-registry > build.sh
```

Recipes may use `if: "+static"` for optional static build settings. Enable these
with `ttrek gen-script -static` or the project's `useFlags: ["+static"]` setting.

The [ttrek.sh website](https://github.com/jerily/ttrek.sh) includes this repository
as its `registry` submodule. After publishing registry changes, update and commit
that submodule's revision in `ttrek.sh` to make the website use them.
