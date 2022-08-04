#!/bin/bash -eux

source common.sh

unpack_source libogg

pushd "$BUILD_DIR/libogg"

emconfigure ./configure --disable-shared --prefix="$INSTALL_DIR"
emmake make
emmake make install

echo "libogg OK"
