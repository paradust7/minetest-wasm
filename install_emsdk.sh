#!/bin/bash -eux

BASE_DIR="$(dirname -- "$(readlink -f -- "$0")")"

cd "$BASE_DIR"

rm -rf emsdk
git clone https://github.com/emscripten-core/emsdk.git

pushd emsdk
./emsdk install 4.0.12
./emsdk activate 4.0.12
popd

./apply_patches.sh emsdk

