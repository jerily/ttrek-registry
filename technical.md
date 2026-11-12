# Recipe authoring

Add each version in its own `<package>/<version>/` directory, keeping existing
versions available. Put `ttrek.json`, patches, and example scripts together.
Use a short, single-line `description` and a top-level `url` pointing to the
project homepage or source repository (not a release archive). Pin source
downloads or Git checkouts to a release or commit. Dependency-test fixtures
link to their directory in this registry.

`dependencies` maps package names to version constraints, for example:

```json
"dependencies": { "tcl": ">=8.6.14", "zlib": "^1.3.2" }
```

Declare everything the package needs to build and run here. `devDependencies`
is used for a root project's development tools; it is ignored when a registry
package is installed as a dependency.

`build.default` is an array of command objects executed in order. Common commands
include `download`, `unpack`, `cd`, `configure`, `cmake_config`, `make`, and
`make_install`. Build steps can refer to `$SOURCE_DIR` and `$INSTALL_DIR`.
Start from a [similar recipe](tjson/1.0.26/ttrek.json).

`download` accepts an optional `filename` relative to the download directory.
`unpack` accepts the same `filename` and an optional `destination` relative to
the package source directory. Both default to the package's main archive/source.

```json
[
  {"cmd": "download", "url": "https://example.com/crt-v1.0.tar.gz", "filename": "crt-v1.0.tar.gz"},
  {"cmd": "unpack", "filename": "crt-v1.0.tar.gz", "destination": "crt/library"}
]
```

Paths are literal; absolute paths and `..` components are rejected. Extraction
strips the archive's top-level directory. Neither operation changes build
environment variables. `cmake_config.source` can select another CMake project
path, including `$DOWNLOAD_DIR` or `$SOURCE_DIR` expressions.


A step or option can be conditional. For example, this CMake option applies
when the `+static` flag is enabled:

```json
{ "name": "BUILD_SHARED_LIBS", "value": "OFF", "if": "+static" }
```

Store named shell scripts as UTF-8 files beside the recipe:

```json
"scripts": {
  "demo-csv": { "file": "run-demo.sh", "args": ["csv"] },
  "demo-json": { "file": "run-demo.sh", "args": ["json"] }
}
```

File references must be plain filenames of regular files in that directory,
not paths or symbolic links. Optional `args` must be an array of strings;
presets are passed literally before user arguments supplied after `--`.
Inline script strings are also supported. After
installation, run a script with `ttrek run -package PACKAGE -script demo-csv`.

To check a recipe, run this from a project initialized with `ttrek init`, using
the path to your registry checkout:

```sh
ttrek gen-script -registry /path/to/ttrek-registry tjson@1.0.26 > build.sh
bash -n build.sh
```

Replace `tjson@1.0.26` with the package and version you are editing. Generation
resolves dependencies and emits the build commands; it does not build packages.
Run `bash build.sh` to test the build, which installs into `build/install` beside
the script. Add `-static` to `gen-script` to check conditional static builds.
