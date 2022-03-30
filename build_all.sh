#!/bin/bash -eux

rm -rf build install www

# Emscripten comes with ports for most of these, but they don't compile
# with pthread support. Wipe the cache and build them ourselves.
emcc --clear-cache --clear-ports

# Dependencies
./build_zlib.sh
./build_libjpeg.sh
./build_libpng.sh    # uses zlib
./build_libogg.sh
./build_libvorbis.sh # uses ogg
./build_freetype.sh  # uses zlib, libpng
./build_zstd.sh
./build_sqlite3.sh
./build_webshims.sh

# Minetest
./pull_minetest.sh
./build_fsroot.sh
./build_minetest.sh
