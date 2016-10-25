# Shadowsocks Server with KCPTUN support Dockerfile

FROM alpine:3.4

ENV SS_VER 2.5.5

ENV KCP_VER 20161009

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
	openssh-server \
RUN \
    apk add --no-cache --virtual .run-deps \
      pcre \
      curl -fSL https://github.com/shadowsocks/shadowsocks-libev/archive/v$SS_VER.tar.gz | tar xz \
      cd shadowsocks-libev-$SS_VER \
      ./configure \
      make \
      make install \
      cd .. \
      rm -rf shadowsocks-libev-$SS_VER \
    apk del .build-deps

RUN \
    apk add --no-cache --virtual .build-deps curl \
    && mkdir -p /opt/kcptun \
    && cd /opt/kcptun \
    && curl -fSL https://github.com/xtaci/kcptun/releases/download/v$KCP_VER/kcptun-linux-amd64-$KCP_VER.tar.gz | tar xz \
    && rm client_linux_amd64 \
    && cd ~ \
    && apk del .build-deps \
    && apk add --no-cache supervisor

RUN curl https://ss.nsupdate.info:axvKQ4TTcE@ipv4.nsupdate.info/nic/update

RUN echo 'root:root' |chpasswd

RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
	sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

RUN mkdir -p /var/run/sshd
	
CMD    ["/usr/sbin/sshd", "-D"]

COPY supervisord.conf /etc/supervisord.conf

ENV KCP_PORT=9443 KCP_MODE=fast MTU=1400 SNDWND=1024 RCVWND=1024

ENV SS_PORT=443 SS_PASSWORD=opera@china SS_METHOD=chacha20 SS_TIMEOUT=600

EXPOSE 22

EXPOSE $SS_PORT/tcp $SS_PORT/udp

EXPOSE $KCP_PORT/udp

ENTRYPOINT ss-server -p $SS_PORT -k $SS_PASSWORD -m $SS_METHOD -t $SS_TIMEOUT -d 8.8.8.8 -d 208.67.222.222 -u --fast-open

ENTRYPOINT ["/usr/bin/supervisord"]
