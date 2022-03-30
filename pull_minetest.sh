#!/bin/bash -eux

source common.sh


# If there's an existing source directory, leave it alone
if [ -d minetest ]; then
  exit
fi

git clone -b webport "https://github.com/paradust7/minetest.git"

pushd minetest/lib/

git clone -b webport "https://github.com/paradust7/irrlicht.git" irrlichtmt
