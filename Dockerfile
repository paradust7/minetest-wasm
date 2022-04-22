FROM ubuntu:21.10 as builder
ARG EMSDK_VERSION=latest

# install deps
RUN apt-get update &&\
	DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y wget python3 git build-essential cmake tclsh zip

# emscripten
RUN wget -O - https://github.com/emscripten-core/emsdk/archive/refs/heads/main.tar.gz | tar xzf -

# build
COPY . /data
RUN cd /emsdk-main &&\
	./emsdk install ${EMSDK_VERSION} &&\
	./emsdk activate ${EMSDK_VERSION} &&\
	cat /data/emcc.patch | patch -p1 &&\
	. /emsdk-main/emsdk_env.sh &&\
	cd /data &&\
	./build_all.sh

FROM nginx:1.21.6 as webserver
COPY --from=builder /data/www /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]