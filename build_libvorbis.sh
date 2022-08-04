#!/bin/bash -eux

source common.sh

unpack_source libvorbis

pushd "$BUILD_DIR/libvorbis"
emconfigure ./configure --disable-shared --prefix="$INSTALL_DIR" --with-ogg="$INSTALL_DIR"
emmake make
emmake make install

echo "libvorbis OK"
