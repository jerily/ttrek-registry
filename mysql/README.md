# MySQL Community Server

`mysql@8.4.13` builds the MySQL 8.4 LTS server and clients from source. Build
from a ttrek project with a C++20 compiler, CMake, and the platform's MySQL
build prerequisites. On Linux, install Bison, patchelf, pkg-config, and the
ncurses, libtirpc, and libaio development packages. [Upstream build prerequisites](https://dev.mysql.com/doc/refman/8.4/en/source-installation-prerequisites.html)

```sh
ttrek gen-script mysql@8.4.13 > build.sh
bash build.sh
```

The standalone build installs under `build/install/mysql`. With `ttrek install`,
use `ttrek-venv/local/mysql` instead. The following commands run as your normal
user and keep the database outside the installation tree. Initialize once, in
an empty data directory. The passwordless root login in this local example is
accessible through a Unix socket inside the private state directory.

```sh
mysql_base="$PWD/build/install/mysql"
state="$PWD/var/mysql"
install -d -m 700 "$state"
"$mysql_base/bin/mysqld" --no-defaults --initialize-insecure \
    --basedir="$mysql_base" --datadir="$state/data"

# Start here on subsequent runs with the same data.
"$mysql_base/bin/mysqld" --no-defaults --daemonize --skip-networking --mysqlx=OFF \
    --basedir="$mysql_base" --datadir="$state/data" --socket="$state/mysql.sock" \
    --pid-file="$state/mysql.pid" --log-error="$state/mysql.log"

"$mysql_base/bin/mysql" --no-defaults --socket="$state/mysql.sock" -u root \
    -e 'CREATE DATABASE IF NOT EXISTS local_app; SELECT VERSION(), @@default_storage_engine;'
"$mysql_base/bin/mysqladmin" --no-defaults --socket="$state/mysql.sock" -u root shutdown
```
