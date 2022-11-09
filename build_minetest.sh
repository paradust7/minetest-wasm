#!/bin/bash -eux

source common.sh

INCREMENTAL=${INCREMENTAL:-false}

pushd "$BUILD_DIR"
if ! $INCREMENTAL; then
  rm -rf minetest
fi
mkdir -p minetest
pushd minetest

export EMSDK_EXTRA="-sUSE_SDL=2"
export CFLAGS="$CFLAGS $EMSDK_EXTRA"
export CXXFLAGS="$CXXFLAGS $EMSDK_EXTRA"
export LDFLAGS="$LDFLAGS $EMSDK_EXTRA -sPTHREAD_POOL_SIZE=20 -s EXPORTED_RUNTIME_METHODS=ccall,cwrap -s INITIAL_MEMORY=2013265920 -sMIN_WEBGL_VERSION=2 -sUSE_WEBGL2 -sWASMFS=1"
export LDFLAGS="$LDFLAGS -L$INSTALL_DIR/lib -larchive -lssl -lcrypto -lemsocket -lwebsocket.js"

# Create a dummy .o file to use as a substitute for the OpenGLES2 / EGL libraries,
# since Emscripten doesn't actually provide those. (the symbols are resolved through
# javascript stubs).
echo > dummy.c
emcc -c dummy.c -o dummy.o
DUMMY_OBJECT="$(pwd)/dummy.o"
mkdir -p dummy_dir
DUMMY_INCLUDE_DIR="$(pwd)/dummy_dir"

if ! $INCREMENTAL; then
    emcmake cmake \
      -DCMAKE_VERBOSE_MAKEFILE=ON \
      -DENABLE_SYSTEM_GMP=OFF \
      -DENABLE_GETTEXT=FALSE \
      -DRUN_IN_PLACE=TRUE \
      -DENABLE_GLES=TRUE \
      -DCMAKE_BUILD_TYPE="$MINETEST_BUILD_TYPE" \
      -DZLIB_INCLUDE_DIR="$INSTALL_DIR/include" \
      -DZLIB_LIBRARY="$INSTALL_DIR/lib/libz.a" \
      -DJPEG_INCLUDE_DIR="$INSTALL_DIR/include" \
      -DJPEG_LIBRARY="$INSTALL_DIR/lib/libjpeg.a" \
      -DPNG_PNG_INCLUDE_DIR="$INSTALL_DIR/include" \
      -DPNG_LIBRARY="$INSTALL_DIR/lib/libpng.a" \
      -DOGG_INCLUDE_DIR="$INSTALL_DIR/include" \
      -DVORBIS_INCLUDE_DIR="$INSTALL_DIR/include" \
      -DOGG_LIBRARY="$INSTALL_DIR/lib/libogg.a" \
      -DVORBIS_LIBRARY="$INSTALL_DIR/lib/libvorbis.a" \
      -DVORBISFILE_LIBRARY="$INSTALL_DIR/lib/libvorbisfile.a" \
      -DFREETYPE_LIBRARY="$INSTALL_DIR/lib/libfreetype.a" \
      -DFREETYPE_INCLUDE_DIRS="$INSTALL_DIR/include/freetype2" \
      -DOPENGLES2_INCLUDE_DIR="$DUMMY_INCLUDE_DIR" \
      -DOPENGLES2_LIBRARY="$DUMMY_OBJECT" \
      -DSQLITE3_LIBRARY="$INSTALL_DIR/lib/libsqlite3.a" \
      -DSQLITE3_INCLUDE_DIR="$INSTALL_DIR/include" \
      -DZSTD_LIBRARY="$INSTALL_DIR/lib/libzstd.a" \
      -DZSTD_INCLUDE_DIR="$INSTALL_DIR/include" \
      -DEGL_LIBRARY="$DUMMY_OBJECT" \
      -DEGL_INCLUDE_DIR="$DUMMY_INCLUDE_DIR" \
      -DCURL_LIBRARY="$INSTALL_DIR/lib/libcurl.a" \
      -DCURL_INCLUDE_DIR="$INSTALL_DIR/include" \
      -DCMAKE_INSTALL_PREFIX="$BUILD_DIR/minetest-install" \
      -G "Unix Makefiles" \
      "$SOURCES_DIR/minetest"
fi

rm -rf "$BUILD_DIR/minetest-install"
emmake make install
