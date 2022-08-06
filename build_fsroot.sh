#!/bin/bash -eux

# Build virtual file system
#
# The files minetest needs to function correctly.
#
# Shaders, fonts, games, etc

source common.sh

# TODO: Use `make package` for this instead.
MTDIR="minetest-5.5.1-win64"
unpack_source $MTDIR

pushd "$BUILD_DIR"

rm -rf fsroot
mkdir fsroot

# Copy root certificates for OpenSSL
mkdir -p fsroot/etc/ssl/certs
# ca-certificates.crt may be a symlink
cat /etc/ssl/certs/ca-certificates.crt > fsroot/etc/ssl/certs/ca-certificates.crt

mv $MTDIR fsroot/minetest

pushd fsroot/minetest

# Don't need the Windows exe/dlls
rm -rf bin

# Emscripten strips empty directories. But bin/ needs to be present so that
# realpath() works on relative paths starting with bin/../
mkdir bin
echo "This is here to ensure bin exists" > bin/readme.txt

# Replace these directories with the ones from the source directory
for I in client builtin clientmods games/devtest textures; do
  rm -rf "$I"
  cp -r "$MINETEST_REPO/$I" "$I"
done

# Copy the irrlicht shaders
cp -r "$IRRLICHT_REPO/media/Shaders" client/shaders/Irrlicht

popd

# Make fsroot.tar
rm -f fsroot.tar
pushd fsroot
tar cf ../fsroot.tar .
popd

# Compress with ZSTD
rm -f fsroot.tar.zst
zstd --ultra -22 fsroot.tar
