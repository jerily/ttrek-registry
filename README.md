# ttrek-registry

Package specifications and build recipes for [ttrek](https://github.com/jerily/ttrek).
This repository was extracted from `jerily/ttrek.sh`, preserving the registry's Git history.

Each package version lives at `<package>/<version>/ttrek.json`. Any patches used
by that recipe are stored beside its specification. Add new versions in separate
directories so existing versions remain available.

`ttrie/0.1.1` provides a static C trie and a Tcl 8.6/9.x extension for exact and
edit-distance search. Its recipe builds the loadable extension by default;
`+static` builds the Tcl wrapper for embedding. Both install `ttrie::core` for CMake.
Shared builds link only the Tcl stub archive.

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
