#!/bin/bash -eux

# Incremental build for making changes to only luanti

export INCREMENTAL=true
./build_minetest.sh
./build_fsroot.sh
./build_www.sh
