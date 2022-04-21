FROM ubuntu:focal as builder

ARG EMSDK_VERSION=latest

COPY . /data

RUN apt update &&\
	DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y wget python3 git build-essential cmake &&\
	wget -O - https://github.com/emscripten-core/emsdk/archive/refs/heads/main.tar.gz | tar xzf - &&\
	cd /emsdk-main &&\
	./emsdk install ${EMSDK_VERSION} &&\
	./emsdk activate ${EMSDK_VERSION} &&\
	source ./emsdk_env.sh &&\
	cd /data &&\
	./build_all.sh