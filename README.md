Minetest-wasm
=============

This is an experimental port of Minetest to the web using emscripten/WebAssembly.


System Requirements
-------------------
This has only been tested on Ubuntu 20.04.

* Ubuntu: apt-get install -y build-essential cmake tclsh

Pre-requisites
--------------
The Emscripten SDK (emsdk) must be installed, activated, and in the PATH.
It is assumed to be installed in $HOME/emsdk (edit `common.sh` to change this).

Apply the patch `emcc.patch` to the emsdk directory. This is needed for configure to work with pthreads.

Building
---------

    cd minetest-wasm
    ./build_all.sh

Installation
------------

If the build completes successfully, the www/ directory will contain the entire application. This 
includes an `.htaccess` file which sets headers that are required (by browsers) to load the app. 
If your webserver does not recognize `.htaccess` files, you may need to set the headers in
another way.
