FROM alpine:edge

LABEL maintainer Sylvain Martin (sylvain@nforcer.com)

# s6 overlay
ARG OVERLAY_VER="v2.0.0.1"
ARG OVERLAY_URL="https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VER}/s6-overlay-amd64.tar.gz"

# Dockerize
ARG DOCKERIZE_VER="v0.6.1"
ARG DOCKERIZE_URL="https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VER}/dockerize-alpine-linux-amd64-${DOCKERIZE_VER}.tar.gz"

ENV PUID=3001 \
    PGID=3000 \
    TZ=America/New_York

RUN echo "Fetching the basics" \
    && echo 'http://dl-cdn.alpinelinux.org/alpine/edge/main' > /etc/apk/repositories \
    && echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
    && echo 'http://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories \
    && apk update \
    && apk upgrade \
    && apk add --no-cache rsyslog jq curl bind-tools openssl nfs-utils rpcbind shadow tzdata \
        ca-certificates coreutils bash git logrotate python3 \
    && apk add --virtual build-dependencies \
        build-base gcc python3-dev linux-headers \
    && echo "**** install Python ****" \
    && if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi \
    && echo "**** install pip ****" \
    && python3 -m ensurepip \
    && rm -r /usr/lib/python*/ensurepip \
    && pip3 install --no-cache --upgrade pip setuptools wheel envtpl\
    && if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi \
    && echo "Installing s6 overlay" \
    && curl -L -s ${OVERLAY_URL} | tar xvzf - -C / \
    && echo "Installing Dockerize" \
    && curl -L -s ${DOCKERIZE_URL} | tar xvzf - -C /usr/local/bin \
    && echo "Installing Cloudflare python API" \ 
    && pip3 install cloudflare netifaces \
    && echo "Cleaning up" \
    && apk del build-dependencies \ 
    && apk del --purge \
    && rm -rf /tmp/* /var/cache/apk/* /usr/src/* \
    && touch /var/log/messages \
    && mkdir -p /etc/crontab /var/spool/rsyslog \
    && chmod 600 /etc/crontab 

COPY rootfs/ /

ENTRYPOINT [ "/init" ]
CMD /bin/ash