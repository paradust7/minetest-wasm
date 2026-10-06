#!/bin/bash -eux

source common.sh

unpack_source libzip

pushd "$BUILD_DIR/libzip"

# libzip uses zlib
export CPPFLAGS="${CPPFLAGS-} -I${INSTALL_DIR}/include --use-port=zlib"
export CFLAGS="$CFLAGS --use-port=zlib"
export LDFLAGS="$LDFLAGS -L${INSTALL_DIR}/lib --use-port=zlib"

emcmake cmake \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR"

emmake make
emmake make install

echo "libzip OK"
