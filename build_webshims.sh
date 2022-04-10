#!/bin/bash -eux

source common.sh

if [ ! -d sources/webshims ]; then
  pushd sources
  git clone "https://github.com/paradust7/webshims.git" webshims
  popd
fi

pushd "$BUILD_DIR"
rm -rf webshims
mkdir webshims
pushd webshims

emcmake cmake -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" "$SRC_DIR/webshims"
emmake make
emmake make install

echo "webshims OK"
