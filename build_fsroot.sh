#!/bin/bash -eux

# Build virtual file system
#
# The files minetest needs to function correctly.
#
# Shaders, fonts, games, etc

source common.sh

pushd "$BUILD_DIR"

rm -rf fsroot
mkdir fsroot
cp -a "minetest-install" fsroot/minetest


#############################################
pushd fsroot/minetest

rm -rf bin unix
# Emscripten strips empty directories. But bin/ needs to be present so that
# realpath() works on relative paths starting with bin/../
mkdir bin
echo "This is here to ensure bin exists" > bin/readme.txt

# Copy the irrlicht shaders
cp -r "$IRRLICHT_REPO/media/Shaders" client/shaders/Irrlicht

rm -rf games/minetest_game
mkdir -p games
cp -a "$SOURCES_DIR"/minetest_game games
cd games/minetest_game
rm -rf ".git" ".github"

popd


#############################################
# Copy root certificates for OpenSSL
pushd fsroot
mkdir -p etc/ssl/certs
# May be a symlink, use cat to copy contents
cat /etc/ssl/certs/ca-certificates.crt > etc/ssl/certs/ca-certificates.crt
popd


# Make fsroot.tar
rm -f fsroot.tar
pushd fsroot
tar cf ../fsroot.tar .
popd

# Compress with ZSTD
rm -f fsroot.tar.zst
zstd --ultra -22 fsroot.tar
