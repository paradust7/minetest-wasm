#!/bin/bash -eux

source common.sh

pushd "$BUILD_DIR"
rm -rf freetype-build
mkdir freetype-build

pushd freetype-build

emcmake cmake \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
  -DZLIB_LIBRARY="$INSTALL_DIR/lib/libz.a" \
  -DZLIB_INCLUDE_DIR="$INSTALL_DIR/include" \
  -DPNG_LIBRARY="$INSTALL_DIR/lib/libpng.a" \
  -DPNG_PNG_INCLUDE_DIR="$INSTALL_DIR/include" \
  "$SOURCES_DIR/freetype"
emmake make
emmake make install

echo "freetype OK"
