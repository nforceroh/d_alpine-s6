FROM alpine:edge

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

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

ARG OVERLAY_VER="v2.2.0.3" 
ARG OVERLAY_URL="https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VER}/s6-overlay-amd64.tar.gz" 

ENV PUID=3001 \
    PGID=3000 \
    TZ=America/New_York

RUN echo "Fetching the basics" \
    && echo 'http://dl-cdn.alpinelinux.org/alpine/edge/main' > /etc/apk/repositories \
    && echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
    && echo 'http://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories \
    && apk --update add --no-cache jq curl bind-tools openssl shadow tzdata \
        ca-certificates coreutils bash git \
    && echo "Installing s6 overlay" \
    && curl -L -s ${OVERLAY_URL} | tar xvzf - -C / \
    && echo "Cleaning up" \
    && apk del --purge \
    && rm -rf /tmp/* /var/cache/apk/* /usr/src/* 

COPY rootfs/ /

#ENTRYPOINT [ "/init" ]
CMD /bin/ash