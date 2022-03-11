FROM alpine

RUN apk add --no-cache --virtual .build-deps \
      git make gcc musl-dev linux-headers openssl-dev zlib-dev libexecinfo-dev \
    && (test -e /mtproxy/sources || git clone --single-branch --depth 1 https://github.com/wention/MTProxy.git /mtproxy/sources) \
    && cd /mtproxy/sources \
    && make -j$(getconf _NPROCESSORS_ONLN)

FROM alpine

RUN apk add --no-cache curl

WORKDIR /mtproxy

COPY --from=0 /mtproxy/sources/objs/bin/mtproto-proxy .
COPY docker-entrypoint.sh /

VOLUME /data
EXPOSE 2398 443

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD [ \
  "--port", "2398", \
  "--http-ports", "443", \
  "--slaves", "2", \
  "--max-special-connections", "60000", \
  "--allow-skip-dh" \
]
