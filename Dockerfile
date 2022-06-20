FROM ubuntu:21.10 as builder
ARG EMSDK_VERSION=latest

# install deps
RUN apt-get update &&\
	DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y wget python3 git build-essential cmake tclsh zip

# emscripten
RUN cd /root &&\
	wget -O - https://github.com/emscripten-core/emsdk/archive/refs/heads/main.tar.gz | tar xzf - &&\
	mv emsdk-main emsdk

# build/patch
COPY . /data
RUN cd /data &&\
	./apply_patches.sh &&\
	cd /root/emsdk &&\
	./emsdk install ${EMSDK_VERSION} &&\
	./emsdk activate ${EMSDK_VERSION} &&\
	. /root/emsdk/emsdk_env.sh &&\
	cd /data &&\
	./build_all.sh

FROM nginx:1.21.6 as webserver
COPY --from=builder /data/www /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]