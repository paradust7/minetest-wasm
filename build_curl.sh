#!/bin/bash -eux

source common.sh

unpack_source curl

# Wrap socket ops
"$SOURCES_DIR/webshims/src/emsocket/wrap.py" "$BUILD_DIR/curl"

pushd "$BUILD_DIR"

rm -rf curl-build
mkdir curl-build
pushd curl-build

# For emsocket.h
export CFLAGS="-I${INSTALL_DIR}/include"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-L${INSTALL_DIR}/lib -lemsocket"

emcmake cmake \
  -DCURL_ZLIB=ON \
  -DZLIB_INCLUDE_DIR="$INSTALL_DIR/include" \
  -DZLIB_LIBRARY="$INSTALL_DIR/lib/libz.a" \
  -DOPENSSL_SSL_LIBRARY="$INSTALL_DIR/lib/libssl.a" \
  -DOPENSSL_CRYPTO_LIBRARY="$INSTALL_DIR/lib/libcrypto.a" \
  -DOPENSSL_INCLUDE_DIR="$INSTALL_DIR/include" \
  -DBUILD_CURL_EXE=OFF \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
  "$BUILD_DIR/curl"

emmake make
emmake make install

echo "curl OK"
