#!/bin/bash -eux

source common.sh

pushd "$BUILD_DIR"
rm -rf zstd-build
mkdir zstd-build

pushd zstd-build

# makefile can't handle parallelism
export MAKEFLAGS=""

export CFLAGS="-D_POSIX_SOURCE=1"
export CXXFLAGS="-D_POSIX_SOURCE=1"
emcmake cmake \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
  "$SOURCES_DIR/zstd/build/cmake"

emmake make
emmake make install

echo "zstd OK"
