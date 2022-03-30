#!/bin/bash -eux

source common.sh

TARNAME="libogg-1.3.5"
TARBALL="libogg-1.3.5.tar.gz"

if [ ! -f sources/"$TARBALL" ]; then
  pushd sources
  wget "https://downloads.xiph.org/releases/ogg/$TARBALL"
  popd
fi

if ! sha256sum sources/"$TARBALL" | grep -q 0eb4b4b9420a0f51db142ba3f9c64b333f826532dc0f48c6410ae51f4799b664; then
  echo "Wrong checksum for $TARNAME"
  exit 1
fi

pushd build

rm -rf "$TARNAME"
tar -zxvf "$SRC_DIR/$TARBALL"

pushd "$TARNAME"

emconfigure ./configure --disable-shared --prefix="$INSTALL_DIR"
emmake make
emmake make install

echo "libogg OK"
