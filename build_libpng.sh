#!/bin/bash -eux

source common.sh

pushd "$BUILD_DIR"
rm -rf libpng
cp -a "$SOURCES_DIR/libpng" libpng

pushd libpng
# For zlib
export CPPFLAGS="-I${INSTALL_DIR}/include"
export LDFLAGS="-L${INSTALL_DIR}/lib"
emconfigure ./configure --disable-shared --prefix="${INSTALL_DIR}"
emmake make
emmake make install
