#!/bin/bash -eux

source common.sh

URL="https://www.openssl.org/source/openssl-1.1.1n.tar.gz"
TARBALL="openssl-1.1.1n.tar.gz"
TARDIR="openssl-1.1.1n"

if [ ! -f sources/"$TARBALL" ]; then
  pushd sources
  wget "$URL" -O "$TARBALL"
  popd
fi

if ! sha256sum sources/"$TARBALL" | grep -q 40dceb51a4f6a5275bde0e6bf20ef4b91bfc32ed57c0552e2e8e15463372b17a; then
  echo "Wrong checksum for $URL"
  exit 1
fi

pushd "$BUILD_DIR"

rm -rf "$TARDIR"
tar -zxvf "$SRC_DIR/$TARBALL"

$SRC_DIR/webshims/src/emsocket/wrap.py "$TARDIR"

pushd "$TARDIR"
patch -p1 < "$BASE_DIR"/openssl.patch

export CFLAGS="-I${INSTALL_DIR}/include -DPEDANTIC"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-L${INSTALL_DIR}/lib -lemsocket"

emconfigure ./Configure linux-generic64 \
  no-asm \
  no-engine \
  no-hw \
  no-weak-ssl-ciphers \
  no-dtls \
  no-shared \
  no-dso \
  -DPEDANTIC \
  --prefix="$INSTALL_DIR" --openssldir=/ssl

sed -i 's|^CROSS_COMPILE.*$|CROSS_COMPILE=|g' Makefile

emmake make build_generated libssl.a libcrypto.a
cp -r include/openssl "$INSTALL_DIR/include"
cp libcrypto.a libssl.a "$INSTALL_DIR/lib"

echo "openssl OK"
