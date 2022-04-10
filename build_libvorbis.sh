#!/bin/bash -eux

source common.sh

TARNAME="libvorbis-1.3.7"
TARBALL="libvorbis-1.3.7.tar.gz"

if [ ! -f "sources/$TARBALL" ]; then
  pushd sources
  wget "https://downloads.xiph.org/releases/vorbis/$TARBALL"
  popd
fi

if ! sha256sum "sources/$TARBALL" | grep -q 0e982409a9c3fc82ee06e08205b1355e5c6aa4c36bca58146ef399621b0ce5ab; then
  echo "Wrong checksum"
  exit 1
fi

pushd "$BUILD_DIR"
rm -rf "$TARNAME"
tar -zxvf "$SRC_DIR/$TARBALL"

pushd "$TARNAME"

emconfigure ./configure --disable-shared --prefix="$INSTALL_DIR" --with-ogg="$INSTALL_DIR"
emmake make
emmake make install

echo "libvorbis OK"
