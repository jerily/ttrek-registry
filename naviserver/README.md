# NaviServer and OpenACS modules

The registry provides NaviServer 4.99.35, 5.0.7, 5.1.1, and 5.1.2 using the
[upstream releases](https://github.com/naviserver-project/naviserver/releases).
The 4.99.35 recipe selects Tcl 8.6. The 5.x recipes support Tcl 8.6 and Tcl 9.

## Run the example

In a new project directory:

```sh
ttrek init -y
ttrek install -registry /path/to/ttrek-registry naviserver@5.1.2
ttrek run -package naviserver -script start-example
```

Open <http://127.0.0.1:8000/> to see `Hello from NaviServer!`. Press Ctrl-C to
stop the foreground server. The script writes its configuration and example page
under `naviserver-example/` in the project. The same command works after
installing `naviserver@4.99.35` or `naviserver@5.0.7`.

## External modules

The 5.1.1 and 5.1.2 module recipes each use the matching upstream modules
archive and depend on that exact NaviServer version. All three modules changed
in the 5.1.2 archive. The bundled versions are nsdbpg 2.10, nssmtpd 2.8,
and nsstats 1.15.

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

For the complete application stack, see the [OpenACS recipe](../openacs/README.md)
and [PostgreSQL server recipe](../postgresql/README.md). Database and instance
initialization are separate from package installation.

Upstream references: [OpenACS releases](https://openacs.org/projects/openacs/download/),
[NaviServer/OpenACS installer](https://github.com/gustafn/install-ns), and
[PostgreSQL source installation](https://www.postgresql.org/docs/16/install-make.html).
