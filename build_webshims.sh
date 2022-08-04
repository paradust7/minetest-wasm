#!/bin/bash -eux

source common.sh

pushd "$BUILD_DIR"
rm -rf webshims-build
mkdir webshims-build
pushd webshims-build

emcmake cmake -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" "$SOURCES_DIR/webshims"
emmake make
emmake make install

echo "webshims OK"
