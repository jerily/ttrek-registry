# ttrek-registry

Package specifications and build recipes for [ttrek](https://github.com/jerily/ttrek).
This repository was extracted from `jerily/ttrek.sh`, preserving the registry's Git history.

Each package version lives at `<package>/<version>/ttrek.json`. Any patches used
by that recipe are stored beside its specification. Add new versions in separate
directories so existing versions remain available.

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

## NaviServer and OpenACS

NaviServer 5.1.1 replaces the former 4.99.30 and 5.0.0-alpha recipes. It uses
the upstream release tarball, including its generated configure script and
documentation. The server includes `nsdb`, `nsssl`, `nslog`, and `revproxy`;
these do not need separate recipes.

The external modules `nsdbpg`, `nssmtpd`, and `nsstats` use the matching
NaviServer 5.1.1 modules archive. Their registry version identifies that archive,
not the individual module's internal version. They depend on NaviServer 5.1.1
so they build against the same installed headers and module makefiles.

- `nsdbpg` supplies the PostgreSQL driver required by OpenACS with PostgreSQL.
  It depends on `libpq` 16.15.0 (upstream PostgreSQL 16.15), which installs the
  client library, headers, and `pg_config`. It does not install a database server,
  `psql`, or `pg_dump`.
- `nssmtpd` supplies optional SMTP delivery/receipt support. Ordinary outgoing
  mail can also use NaviServer's built-in `ns_sendmail` with an external relay.
- `nsstats` supplies optional diagnostics. Its Tcl/ADP files are installed in
  `share/nsstats`, outside the public document root. For OpenACS, copy them into
  the application's `packages/acs-subsite/www/admin/` directory and configure
  the module using NaviServer's supplied OpenACS configuration.

For the released OpenACS 5.10.1 line, select Tcl 8.6 explicitly:

```sh
ttrek gen-script -registry /path/to/ttrek-registry \
  naviserver@5.1.1 nsdbpg@5.1.1 nssmtpd@5.1.1 nsstats@5.1.1 \
  'tcl@^8.6.15' > build.sh
bash build.sh
```

These recipes target shared builds; do not use `-static` for this stack. TLS uses
OpenSSL 3.5. HTTP/3 is not enabled; it would additionally require OpenSSL 4.0.2+
and an nghttp3 recipe. Installing the modules does not enable listeners or create
an OpenACS instance.

A full PostgreSQL recipe is feasible with modest additional work: build the
server and client utilities, coordinate ownership of the files also supplied by
`libpq`, and test a temporary database cluster. A complete OpenACS recipe is a
larger follow-up: add NSF/XOTcl and Tcllib, verify tDOM and a NaviServer-enabled
Thread build, install the OpenACS sources, and provide an explicit setup step for
database creation, credentials, configuration, schema installation, and service
startup. Database initialization should be separate from package installation.
Neither full PostgreSQL nor OpenACS provisioning is included here.

Upstream references: [OpenACS releases](https://openacs.org/projects/openacs/download/),
[NaviServer/OpenACS installer](https://github.com/gustafn/install-ns), and
[PostgreSQL source installation](https://www.postgresql.org/docs/16/install-make.html).
