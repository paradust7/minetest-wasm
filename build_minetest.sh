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
export LDFLAGS="$LDFLAGS $EMSDK_EXTRA -sPTHREAD_POOL_SIZE=20 -s EXPORTED_RUNTIME_METHODS=ccall,cwrap -s INITIAL_MEMORY=2013265920 -sMIN_WEBGL_VERSION=2 -sUSE_WEBGL2"
export LDFLAGS="$LDFLAGS -L$INSTALL_DIR/lib -lssl -lcrypto -lemsocket -lwebsocket.js"

# Used by CMakeFiles.txt in the webport
export FSROOT_DIR="$BUILD_DIR/fsroot"

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
      -G "Unix Makefiles" \
      "$BASE_DIR/minetest"
fi

if $INCREMENTAL; then
  emmake make -j1
else
  emmake make -j4
fi

echo "Installing into www/"
rm -rf "$WWW_DIR"
mkdir "$WWW_DIR"

FILES="minetest.data minetest.js minetest.wasm minetest.worker.js"

for I in $FILES; do
  cp src/"$I" "$WWW_DIR"
done

if [ -f src/minetest.wasm.map ]; then
  cp src/minetest.wasm.map "$WWW_DIR"
fi

cp "$BASE_DIR/static/index.html" "$WWW_DIR"
cp "$BASE_DIR/static/.htaccess" "$WWW_DIR"

echo "DONE"

popd
popd

# Optional script to upload to webserver
if [ -f upload.sh ]; then
  ./upload.sh
fi
