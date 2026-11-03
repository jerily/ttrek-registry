# OpenACS

`openacs@5.10.1` packages the released OpenACS core and web installer from the
official `openacs-5-10-1-final` GitHub tag. Optional applications can be added
through OpenACS's package manager. This recipe includes the PostgreSQL server
package and the dependencies needed to run OpenACS with NaviServer:

- NaviServer 5.1.1, `nsdbpg`, `nssmtpd`, and `nsstats`.
- Tcl 8.6.18 and a NaviServer-enabled Thread 2.8.13 build.
- NSF/NX/XOTcl 2.5.0, Tcllib 2.0, and tDOM 0.9.6.
- PostgreSQL 16.15 and its client libraries.

The released OpenACS line uses Tcl 8.6. Use a shared build; `-static` is not
supported for this application stack.

The installer is patched to use NaviServer's response headers API so streaming
installation pages finish correctly on persistent HTTP connections.

```sh
ttrek gen-script -registry /path/to/ttrek-registry openacs@5.10.1 > build.sh
bash build.sh
```

The recipe installs a source template in `build/install/share/openacs-5.10.1`
and `build/install/bin/openacs-create-instance`. The helper copies the template
into a new writable directory, adds a NaviServer configuration, and puts
`nsstats` in OpenACS's protected admin directory. It refuses an existing
destination. Rebuilding the package therefore leaves existing instances and
uploaded files alone.

The Tcl recipe installs private headers for NSF and omits bundled extension
packages. `thread-naviserver` builds the Thread sources shipped in Tcl 8.6.18
with `--with-naviserver` and installs them in `lib/thread-ns2.8.13`.

## Start a local instance

Run these commands as your ordinary account after the build. They create a new
local PostgreSQL cluster using peer authentication over a Unix socket; it does
not listen on TCP. Keep the runtime directory outside `build/install`.

```sh
OACS_PREFIX="$PWD/build/install"
OACS_RUNTIME="$PWD/openacs-local"
mkdir -m 700 "$OACS_RUNTIME"
mkdir "$OACS_RUNTIME/socket"

"$OACS_PREFIX/postgresql/bin/initdb" -D "$OACS_RUNTIME/db" \
  --encoding=UTF8 --no-locale --auth-local=peer --auth-host=reject
"$OACS_PREFIX/postgresql/bin/pg_ctl" -D "$OACS_RUNTIME/db" \
  -l "$OACS_RUNTIME/postgres.log" \
  -o "-k '$OACS_RUNTIME/socket' -p 55432 -c listen_addresses=''" -w start
"$OACS_PREFIX/postgresql/bin/createdb" \
  -h "$OACS_RUNTIME/socket" -p 55432 --encoding=UTF8 openacs
"$OACS_PREFIX/postgresql/bin/psql" \
  -h "$OACS_RUNTIME/socket" -p 55432 -d openacs \
  -v ON_ERROR_STOP=1 -c 'CREATE EXTENSION hstore'

"$OACS_PREFIX/bin/openacs-create-instance" "$OACS_RUNTIME/site"
PGHOST="$OACS_RUNTIME/socket" \
oacs_db_host=localhost \
oacs_db_port=55432 \
oacs_db_name=openacs \
oacs_db_user="$(id -un)" \
oacs_httpport=8000 \
  "$OACS_PREFIX/bin/nsd" -f -t "$OACS_RUNTIME/site/etc/ttrek-config.tcl"
```

Open `http://127.0.0.1:8000/` to install the schema and create the administrator
account. The installer stops NaviServer when it finishes; rerun the last command
to start the installed application. Stop NaviServer with Ctrl-C, then stop the
database with:

```sh
"$OACS_PREFIX/postgresql/bin/pg_ctl" -D "$OACS_RUNTIME/db" -m fast -w stop
```

For local sockets, `nsdbpg` treats `localhost` as libpq's default host, so
`PGHOST` selects the private socket directory. A socket path cannot be used
directly as `oacs_db_host` with the bundled driver.

For an existing database, skip cluster creation and supply the appropriate
`oacs_db_host`, `oacs_db_port`, `oacs_db_name`, and `oacs_db_user`. NaviServer's
`oacs_db_passwordfile` setting reads a password from a private file. Configure
TLS, mail delivery, database credentials, and service supervision for the actual
deployment; package installation does not provision those settings.

## Verify the installation

From the registry checkout, run:

```sh
python3 openacs/5.10.1/smoke.py /absolute/path/to/build/install
```

The test creates a temporary PostgreSQL cluster and OpenACS instance, completes
the web installer, and checks application startup and `pg_dump`. It stops both
processes and removes successful test instances; failed runs retain their logs.

Upstream: [OpenACS 5.10.1 release](https://openacs.org/news/item?item_id=6173612),
[tagged source](https://github.com/openacs/openacs-core/tree/openacs-5-10-1-final),
and [NaviServer/OpenACS installer](https://github.com/gustafn/install-ns).
