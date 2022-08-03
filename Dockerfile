FROM ubuntu:22.04

# install deps
RUN \
	   apt-get update \
	&& DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y \
		wget \
		python3 \
		git \
		build-essential \
		cmake \
		tclsh \
		zip

COPY . /minetest-wasm

# Install emsdk
RUN \
	   cd "$HOME" \
	&& echo "Building from $(pwd)" \
	&& git clone --depth 1 https://github.com/emscripten-core/emsdk.git \
	&& cd emsdk \
	&& ./emsdk install latest \
	&& ./emsdk activate latest

# Build minetest-wasm
RUN \
	   cd "$HOME"/emsdk \
	&& . ./emsdk_env.sh \
	&& cd /minetest-wasm \
	&& ./apply_patches.sh \
	&& ls -la \
	&& ./build_all.sh
