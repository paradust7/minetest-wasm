#!/bin/bash -eux

source common.sh

if [ ! -d sources/zlib ]; then
  pushd sources
  git clone "https://github.com/madler/zlib.git" zlib
  popd
fi

pushd build
rm -rf zlib
cp -a "$SRC_DIR/zlib" zlib

pushd zlib
emconfigure ./configure --static --prefix="$INSTALL_DIR"
emmake make
emmake make install

echo "ZLIB OK"
