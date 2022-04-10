#!/bin/bash -eux

source common.sh

if [ ! -d sources/libjpeg ]; then
  pushd sources
  git clone "https://github.com/libjpeg-turbo/libjpeg-turbo.git" libjpeg
  popd
fi

pushd "$BUILD_DIR"
rm -rf libjpeg
mkdir -p libjpeg

pushd libjpeg
emcmake cmake \
-DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
-DWITH_SIMD=0 \
"$SRC_DIR/libjpeg"

emmake make
emmake make install

echo "libjpeg OK"
