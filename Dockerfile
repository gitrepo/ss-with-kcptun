# Shadowsocks Server with KCPTUN support Dockerfile

FROM alpine:3.4

ENV SS_VER 2.5.5

ENV KCP_VER 20161105

RUN \
    apk add --no-cache --virtual .build-deps \
        curl \
        autoconf \
        build-base \
        libtool \
        linux-headers \
        openssl-dev \
        asciidoc \
        xmlto \
        pcre-dev \
    && apk add --no-cache --virtual .run-deps \
        pcre \
    && curl -fSL https://github.com/shadowsocks/shadowsocks-libev/archive/v$SS_VER.tar.gz | tar xz \
    && cd shadowsocks-libev-$SS_VER \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm -rf shadowsocks-libev-$SS_VER \
    && mkdir -p /opt/kcptun \
    && cd /opt/kcptun \
    && curl -fSL https://github.com/xtaci/kcptun/releases/download/v$KCP_VER/kcptun-linux-amd64-$KCP_VER.tar.gz | tar xz \
    && rm client_linux_amd64 \
    && apk del .build-deps

RUN cd ~

RUN curl -fSL https://github.com/gitrepo/ss-with-kcptun/raw/master/entrypoint.sh

RUN chmod +x ~/entrypoint.sh

ENV SS_PORT=443 SS_PASSWORD=sskcptun SS_METHOD=chacha20 SS_TIMEOUT=600

ENV KCP_PORT=29900 KCP_TARGET=127.0.0.1:443 KCP_CRYPT=salsa20 KCP_MODE=fast2 KCP_MTU=1400 KCP_NOCOMP=false KCPTUN_KEY=sskcptun

EXPOSE $SS_PORT/tcp $SS_PORT/udp $KCP_PORT/udp

ENTRYPOINT ["~/entrypoint.sh"]
