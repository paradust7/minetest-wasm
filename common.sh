BASE_DIR="$(dirname -- "$(readlink -f -- "$0")")"
cd "$BASE_DIR"

# Debug / Release
export BUILD_KIND="${BUILD_KIND:-release}"

case $BUILD_KIND in
  debug)
    export MINETEST_BUILD_TYPE="Debug"
    export COMMON_CFLAGS="-O0 -g -gsource-map --source-map-base=/dev/"
    export COMMON_LDFLAGS="-sSAFE_HEAP=1 -sASSERTIONS=2 -sDEMANGLE_SUPPORT=1"
    export BUILD_SUFFIX="-debug"
    ;;
  profile)
    export MINETEST_BUILD_TYPE="Release"
    export COMMON_CFLAGS="--profiling -O2 -g -gsource-map --source-map-base=/dev/"
    export COMMON_LDFLAGS=""
    export BUILD_SUFFIX="-profile"
    ;;
  release)
    export MINETEST_BUILD_TYPE="Release"
    export COMMON_CFLAGS="-O2"
    export COMMON_LDFLAGS=""
    export BUILD_SUFFIX=""
    ;;
  *)
    echo "Unknown build kind: $BUILD_KIND"
    exit 1
esac

SRC_DIR="$BASE_DIR/sources"
BUILD_DIR="$BASE_DIR/build$BUILD_SUFFIX"
INSTALL_DIR="$BASE_DIR/install"
WWW_DIR="$BASE_DIR/www"
mkdir -p "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR"

export CFLAGS="$COMMON_CFLAGS -pthread -sUSE_PTHREADS=1 -fexceptions"
export CXXFLAGS="$COMMON_CFLAGS -pthread -sUSE_PTHREADS=1 -fexceptions"
export LDFLAGS="$COMMON_LDFLAGS -pthread -sUSE_PTHREADS=1 -fexceptions -sEXIT_RUNTIME"

export EMSDK_ROOT="$HOME/emsdk"
export EMSDK_SYSLIB="${EMSDK_ROOT}/upstream/emscripten/cache/sysroot/lib/wasm32-emscripten"
export EMSDK_SYSINCLUDE="${EMSDK_ROOT}/upstream/emscripten/cache/sysroot/include"

export MINETEST_REPO="$BASE_DIR/minetest"
export IRRLICHT_REPO="$BASE_DIR/minetest/lib/irrlichtmt"
