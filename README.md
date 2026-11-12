# ttrek-registry

The public package registry for [ttrek](https://github.com/jerily/ttrek).
Recipes describe where to get a package's source, which dependencies it needs,
and how to build and install it.

With ttrek installed, download or refresh the registry and search for packages:

```sh
ttrek sync
ttrek search tjson
```

In your project directory:

```sh
ttrek init -y
ttrek install tjson
```

Each recipe lives at `<package>/<version>/ttrek.json`. The main fields are:

| Field | Purpose |
| --- | --- |
| `name`, `version` | Package name and version, matching the directory path. |
| `description` | A short description shown in search results. |
| `license` | SPDX license identifier or expression for the upstream package. |
| `dependencies` | Package names mapped to version constraints. |
| `build.default` | Ordered build steps: fetch source, configure, compile, install. |
| `scripts` | Optional named commands, such as demos, to run after installation. |

See [a complete recipe](tjson/1.0.26/ttrek.json) and
[technical.md](technical.md) for recipe authoring and local checks.
For CLI usage, see the [ttrek documentation](https://github.com/jerily/ttrek/blob/main/docs/readme.md).
