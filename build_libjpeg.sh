#!/bin/bash -eux

source common.sh

pushd "$BUILD_DIR"
rm -rf libjpeg
mkdir -p libjpeg

pushd libjpeg

# makefile can't handle parallelism
export MAKEFLAGS=""

emcmake cmake \
-DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
-DWITH_SIMD=0 \
"$SOURCES_DIR/libjpeg"

emmake make
emmake make install

echo "libjpeg OK"
