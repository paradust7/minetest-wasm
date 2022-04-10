#!/bin/bash -eux

source common.sh

if [ ! -d sources/libpng ]; then
  pushd sources
  git clone https://git.code.sf.net/p/libpng/code libpng
  popd
fi

pushd "$BUILD_DIR"
rm -rf libpng
cp -a "$SRC_DIR/libpng" libpng

pushd libpng
# For zlib
export CPPFLAGS="-I${INSTALL_DIR}/include"
export LDFLAGS="-L${INSTALL_DIR}/lib"
emconfigure ./configure --disable-shared --prefix="${INSTALL_DIR}"
emmake make
emmake make install
