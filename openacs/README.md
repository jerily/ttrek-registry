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

## Install

Create a project using the supplied [project spec](ttrek.json), then install
OpenACS and its dependencies:

```sh
mkdir openacs-project
cd openacs-project
cp /path/to/ttrek-registry/openacs/ttrek.json ./ttrek.json
ttrek install -registry /path/to/ttrek-registry
```

The project spec declares `openacs@5.10.1` as a dependency and provides the local
instance scripts below. In an existing project, use
`ttrek install -registry /path/to/ttrek-registry openacs@5.10.1` and copy the
`scripts` entries into your project's `ttrek.json`. Named scripts belong to the
project spec; installing a dependency does not import its scripts.

The recipe installs a source template in `ttrek-venv/local/share/openacs-5.10.1`
and `ttrek-venv/local/bin/openacs-create-instance`. The helper copies the template
into a new writable directory, adds a NaviServer configuration, and puts
`nsstats` in OpenACS's protected admin directory. It refuses an existing
destination. Rebuilding the package therefore leaves existing instances and
uploaded files alone.

The Tcl recipe installs private headers for NSF and omits bundled extension
packages. `thread-naviserver` builds the Thread sources shipped in Tcl 8.6.18
with `--with-naviserver` and installs them in `lib/thread-ns2.8.13`.

## Start a local instance

Run these commands as your ordinary account from the project directory after
installation:

```sh
ttrek run -script init-local
ttrek run -script start-local
```

`init-local` creates `openacs-local` outside the package installation tree, with
private permissions, a PostgreSQL cluster, the `openacs` database with `hstore`,
and a writable OpenACS instance. It uses peer authentication over a private Unix
socket on port 55432 and does not listen on TCP. Run initialization only once;
it refuses an existing runtime directory. PostgreSQL stops when initialization
finishes, including on failure after startup.

`start-local` starts PostgreSQL and runs NaviServer in the foreground. It stops
PostgreSQL when NaviServer exits or you stop it with Ctrl-C.

Open `http://127.0.0.1:8000/` to install the schema and create the administrator
account. The installer stops NaviServer when it finishes; run
`ttrek run -script start-local` again to start the installed application.

The scripts use `PROJECT_HOME`, which `ttrek run` sets to the project directory,
so its change of working directory does not affect these paths. To use another
installation or runtime directory, export absolute paths as `OACS_PREFIX` and
`OACS_RUNTIME` before both commands. Keep runtime data outside `ttrek-venv` and
the installation prefix. To change the HTTP port:

```sh
oacs_httpport=8001 ttrek run -script start-local
```

For local sockets, `nsdbpg` treats `localhost` as libpq's default host, so
`PGHOST` selects the private socket directory. A socket path cannot be used
directly as `oacs_db_host` with the bundled driver.

For an existing database, create an instance with `openacs-create-instance` and
run `nsd` directly, supplying the appropriate `oacs_db_host`, `oacs_db_port`,
`oacs_db_name`, and `oacs_db_user`. The local scripts manage their own cluster.
NaviServer's `oacs_db_passwordfile` setting reads a password from a private file. Configure
TLS, mail delivery, database credentials, and service supervision for the actual
deployment; package installation does not provision those settings.

## Generate a standalone build script

For a build script that can run independently of `ttrek`, use `gen-script`
instead of `ttrek install`. From the project directory containing the supplied
`ttrek.json`:

```sh
ttrek gen-script -registry /path/to/ttrek-registry > build.sh
bash build.sh
export OACS_PREFIX="$PWD/build/install"
ttrek run -script init-local
ttrek run -script start-local
```

Generated builds install under `build/install`; `ttrek install` uses
`ttrek-venv/local`. Keep `OACS_PREFIX` set when starting a generated installation.

## Verify the installation

From the registry checkout, run:

```sh
python3 openacs/5.10.1/smoke.py /absolute/path/to/openacs-project/ttrek-venv/local
```

The test runs the project's named scripts through `ttrek`, completes the web
installer, and checks application restart, `pg_dump`, and shutdown on Ctrl-C.
It stops both processes and removes successful test instances; failed runs
retain their logs. It uses `ttrek` from `PATH`; pass a binary path as the second
argument to test another build.

Upstream: [OpenACS 5.10.1 release](https://openacs.org/news/item?item_id=6173612),
[tagged source](https://github.com/openacs/openacs-core/tree/openacs-5-10-1-final),
and [NaviServer/OpenACS installer](https://github.com/gustafn/install-ns).
