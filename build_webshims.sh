#!/bin/bash -eux

WEBSHIMS_REV=01b29b520fa2c97f9c8f79b4bfd5ae67ecba6e06

source common.sh

if [ ! -d sources/webshims ]; then
  pushd sources
  git clone "https://github.com/paradust7/webshims.git" webshims
  popd
fi

pushd sources/webshims
REV=`git rev-parse HEAD`
popd

if [ "$REV" != "$WEBSHIMS_REV" ]; then
    set +x
    echo "---------------------------------------------------------------"
    echo "ERROR: sources/webshim on wrong revision"
    echo "--------------------------------------------------------------"
    echo "Expected revision: $WEBSHIMS_REV"
    echo "Actual revision: $REV"
    echo "---------------------------------------------------------------"
    echo "Please 'git pull' or delete this directory before proceeding"
    exit 1
fi

pushd "$BUILD_DIR"
rm -rf webshims
mkdir webshims
pushd webshims

emcmake cmake -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" "$SRC_DIR/webshims"
emmake make
emmake make install

echo "webshims OK"
