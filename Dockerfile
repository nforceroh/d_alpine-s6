FROM alpine:edge

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
ARG BASE_IMAGE

LABEL \
  org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.name="ocp_alpine-s6" \
  org.label-schema.description="alpine linux base image" \
  org.label-schema.url="https://github.com/nforceroh/ocp_alpine-s6" \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.vcs-url="https://github.com/nforceroh/ocp_alpine-s6" \
  org.label-schema.vendor="nforceroh" \
  org.label-schema.version=$VERSION \
  org.label-schema.schema-version="1.0"

# s6 overlay and # Dockerize

ENV DOCKERIZE_VER="v0.6.1" \
    OVERLAY_VER="3.1.2.1" \
    S6_GLOBAL_PATH=/command:/usr/bin:/bin:/usr/local/bin:/usr/sbin:/sbin \
    PUID=3001 \
    PGID=3000 \
    TZ=America/New_York \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0


ADD https://github.com/just-containers/s6-overlay/releases/download/v${OVERLAY_VER}/s6-overlay-noarch.tar.xz /tmp
ADD https://github.com/just-containers/s6-overlay/releases/download/v${OVERLAY_VER}/s6-overlay-x86_64.tar.xz /tmp
ADD https://github.com/just-containers/s6-overlay/releases/download/v${OVERLAY_VER}/syslogd-overlay-noarch.tar.xz /tmp
ADD https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VER}/dockerize-alpine-linux-amd64-${DOCKERIZE_VER}.tar.gz /tmp

RUN echo "Fetching the basics" \
    && echo 'https://dl-cdn.alpinelinux.org/alpine/edge/main' > /etc/apk/repositories \
    && echo 'https://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
    && echo 'https://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories \
    && apk update \
    && apk upgrade \
    && apk add -U jq curl bind-tools openssl shadow tzdata xz \
        ca-certificates coreutils bash git \
    && echo "Installing s6 overlay and syslogd" \
    && tar -C / -Jvxpf /tmp/s6-overlay-noarch.tar.xz \
    && tar -C / -Jvxpf /tmp/s6-overlay-x86_64.tar.xz \
    && tar -C / -Jvxpf /tmp/syslogd-overlay-noarch.tar.xz \
    && echo "Installing dockerize" \
    && tar -C /usr/local/bin -xzvf /tmp/dockerize-alpine-linux-amd64-${DOCKERIZE_VER}.tar.gz \
    && echo "Cleaning up" \
    && apk del --purge \
    && rm -rf /tmp/* /var/cache/apk/* /usr/src/* 

COPY rootfs/ /

ENTRYPOINT [ "/init" ]
#CMD /bin/ash