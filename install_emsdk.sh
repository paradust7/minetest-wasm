#!/bin/bash -eux

BASE_DIR="$(dirname -- "$(readlink -f -- "$0")")"

cd "$BASE_DIR"

rm -rf emsdk
git clone https://github.com/emscripten-core/emsdk.git

pushd emsdk
./emsdk install 3.1.25
./emsdk activate 3.1.25
popd

./apply_patches.sh emsdk

