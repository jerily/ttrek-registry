#!/bin/sh
set -eu

# The installed launcher initializes SQLite before starting the local server.
exec "$PROJECT_INSTALL_DIR/bin/example-personal-site" "$@"
