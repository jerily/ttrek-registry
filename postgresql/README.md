# PostgreSQL

`postgresql@16.15.0` builds upstream PostgreSQL 16.15, including the database
server, command-line clients, PL/pgSQL, development files, and the available
contrib extensions (including `hstore`, `pgcrypto`, and `pg_trgm`). It enables
OpenSSL and zlib and omits optional ICU and readline dependencies.

```sh
ttrek gen-script -registry /path/to/ttrek-registry postgresql@16.15.0 > build.sh
bash build.sh
```

The complete PostgreSQL distribution is installed under `build/install/postgresql`.
Use its `bin` directory for `postgres`, `initdb`, `pg_ctl`, `psql`, `pg_dump`, and
`pg_config`. Keeping these files together avoids collisions with the separate
`libpq` package used by NaviServer's `nsdbpg` driver. The private PostgreSQL client
library and the standalone `libpq` package are both built from PostgreSQL 16.15.

Package installation does not initialize a database cluster, create roles, start
a server, or install an operating-system service. Choose a data directory outside
the package installation tree and run `initdb` as the account that will run the
server. See the [OpenACS instructions](../openacs/README.md) for a local example.

Upstream: [source installation](https://www.postgresql.org/docs/16/install-make.html).
