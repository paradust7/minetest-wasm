#!/bin/bash -eux

source common.sh

if [ ! -d sources/zstd ]; then
  pushd sources
  git clone https://github.com/facebook/zstd.git zstd

  pushd zstd
  git checkout v1.5.2
  popd

  popd
fi

pushd "$BUILD_DIR"
rm -rf zstd
mkdir zstd

pushd zstd
export CFLAGS="-D_POSIX_SOURCE=1"
export CXXFLAGS="-D_POSIX_SOURCE=1"
emcmake cmake \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
  "$SRC_DIR/zstd/build/cmake"

emmake make
emmake make install

echo "zstd OK"
