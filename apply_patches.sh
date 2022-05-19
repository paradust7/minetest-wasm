#!/bin/bash -eu

source common.sh

cd "$EMSDK_ROOT"

patch -p1 < "$BASE_DIR/emsdk_emcc.patch"
patch -p1 < "$BASE_DIR/emsdk_file_packager.patch"
