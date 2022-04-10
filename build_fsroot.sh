#!/bin/bash -eux

# Build virtual file system
#
# All the files minetest needs to function correctly.
#
# Shaders, fonts, games, etc
#
# The only source for this seems to be the official distribution.
# There must be a script to build it somewhere, but I haven't found it.

source common.sh

UPSTREAM="https://github.com/minetest/minetest/releases/download/5.5.0/minetest-5.5.0-win64.zip"
ZIPFILE="minetest-5.5.0-win64.zip"
ZIPDIR="minetest-5.5.0-win64"

if [ ! -d "$MINETEST_REPO" ] || [ ! -d "$IRRLICHT_REPO" ; then
    echo "Minetest source not found"
    exit 1
fi

if [ ! -f sources/"$ZIPFILE" ]; then
    pushd sources
    wget "$UPSTREAM"
    popd
fi

pushd "$BUILD_DIR"
rm -rf "$ZIPDIR"
unzip "$SRC_DIR"/"$ZIPFILE"

rm -rf fsroot
mkdir fsroot

# Copy root certificates for OpenSSL
mkdir -p fsroot/etc/ssl/certs
# ca-certificates.crt may be a symlink
cat /etc/ssl/certs/ca-certificates.crt > fsroot/etc/ssl/certs/ca-certificates.crt

mv "$ZIPDIR" fsroot/minetest

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
