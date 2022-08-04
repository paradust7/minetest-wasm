#!/bin/bash -eux

source common.sh

pushd "$BUILD_DIR"
rm -rf zlib
cp -a "$SOURCES_DIR/zlib" zlib

pushd zlib
emconfigure ./configure --static --prefix="$INSTALL_DIR"
emmake make
emmake make install

echo "ZLIB OK"
