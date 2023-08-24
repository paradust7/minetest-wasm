#!/bin/bash -eux

source common.sh

unpack_source SQLite

pushd "$BUILD_DIR/SQLite"
export BUILD_CC="gcc"
emconfigure ./configure --disable-tcl --disable-shared --prefix="$INSTALL_DIR" cross_compiling=yes
emmake make
emmake make install

echo "sqlite3 OK"
