#!/bin/bash -eux

source common.sh

if [ ! -f sources/sqlite.tar.gz ]; then
  pushd sources
  wget "https://www.sqlite.org/src/tarball/sqlite.tar.gz?r=release" -O sqlite.tar.gz
  popd
fi

pushd build
rm -rf sqlite
tar -zxvf "$SRC_DIR/sqlite.tar.gz"

pushd sqlite
export BUILD_CC="gcc"
emconfigure ./configure --disable-shared --prefix="$INSTALL_DIR" cross_compiling=yes
emmake make
emmake make install

echo "sqlite3 OK"
