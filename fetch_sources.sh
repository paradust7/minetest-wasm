#!/bin/bash -eux

source common.sh

#
# To prevent spurious build failures (due to transient network issues),
# these external archive files are checked into the repository under
# sources/, but it is always possible to re-download them with:
#
#    $ rm -rf sources
#    $ ./fetch_sources.sh
#

getsource "https://downloads.xiph.org/releases/ogg/libogg-1.3.5.tar.gz" 0eb4b4b9420a0f51db142ba3f9c64b333f826532dc0f48c6410ae51f4799b664
getsource "https://downloads.xiph.org/releases/vorbis/libvorbis-1.3.7.tar.gz" 0e982409a9c3fc82ee06e08205b1355e5c6aa4c36bca58146ef399621b0ce5ab
getsource "https://www.sqlite.org/src/tarball/698edb77/SQLite-698edb77.tar.gz" b1568dc5d17788b9dd9575ecd224b3f7985b51764bc2f34f4808d851332840ef
getsource "https://www.openssl.org/source/openssl-1.1.1n.tar.gz" 40dceb51a4f6a5275bde0e6bf20ef4b91bfc32ed57c0552e2e8e15463372b17a
getsource "https://curl.se/download/curl-7.82.0.tar.bz2" 46d9a0400a33408fd992770b04a44a7434b3036f2e8089ac28b57573d59d371f
getsource "https://www.libarchive.org/downloads/libarchive-3.6.1.tar.xz" 5a411aceb978f43e626f0c2d1812ddd8807b645ed892453acabd532376c148e6

# These are never checked into the repo, since they are separate git repos.
# Be sure to add new entries here to .gitignore
getrepo zlib "https://github.com/madler/zlib.git" 21767c654d31d2dccdde4330529775c6c5fd5389
getrepo libjpeg "https://github.com/libjpeg-turbo/libjpeg-turbo.git" 2ee7264d40910f2529690de327988ce0c2276812
getrepo libpng "https://git.code.sf.net/p/libpng/code" a37d4836519517bdce6cb9d956092321eca3e73b
getrepo freetype "https://gitlab.freedesktop.org/freetype/freetype.git" a8e4563c3418ed74d39019a6c5e2122d12c8f56f
getrepo zstd "https://github.com/facebook/zstd.git" e47e674cd09583ff0503f0f6defd6d23d8b718d3

# Minetest Game
getrepo minetest_game "https://github.com/minetest/minetest_game.git" 052ccb09280a1fa52022c7e120437b1e6dc82771

# These repos are part of the fork
getrepo webshims "https://github.com/paradust7/webshims.git" 0767fdedd87f61a28a34f6444b669caf563a9fd5
getrepo minetest "https://github.com/paradust7/minetest.git" 34aa17a75d08c686b00b747ed543a8aa0a8ac049
