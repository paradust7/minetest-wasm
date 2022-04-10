#!/bin/bash -eux

source common.sh

if [ ! -d sources/freetype ]; then
  pushd sources
  git clone https://gitlab.freedesktop.org/freetype/freetype.git freetype
  popd
fi

pushd "$BUILD_DIR"
rm -rf freetype
mkdir freetype

pushd freetype

emcmake cmake \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
  -DZLIB_LIBRARY="$INSTALL_DIR/lib/libz.a" \
  -DZLIB_INCLUDE_DIR="$INSTALL_DIR/include" \
  -DPNG_LIBRARY="$INSTALL_DIR/lib/libpng.a" \
  -DPNG_PNG_INCLUDE_DIR="$INSTALL_DIR/include" \
  "$SRC_DIR/freetype"
emmake make
emmake make install

echo "freetype OK"
