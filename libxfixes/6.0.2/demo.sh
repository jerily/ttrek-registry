#!/bin/sh
set -eu
: "${PROJECT_INSTALL_DIR:?Run with ttrek run -package libxfixes -script demo}"
export PKG_CONFIG_PATH="$PROJECT_INSTALL_DIR/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
pkg-config --modversion xfixes
