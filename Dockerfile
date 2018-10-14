#
# Dockerfile for shadowsocks-libev
#

FROM alpine
LABEL maiter="Shawn Hao"

ENV BUILD_DEPS git asciidoc xmlto
ENV RUNTIME_DEPS autoconf automake build-base c-ares-dev libev-dev libtool libsodium-dev linux-headers mbedtls-dev pcre-dev
ENV SSSDIR /tmp/shadowsocks-libev
ENV PORT=8399

# Set up building environment
RUN set -x \
 && apk add --no-cache --virtual .build-deps ${BUILD_DEPS} ${RUNTIME_DEPS} \
# Get the latest shadowsocks-libev code, build and install
 && git clone https://github.com/shadowsocks/shadowsocks-libev.git ${SSSDIR} \
 && cd ${SSSDIR} && git submodule update --init --recursive \
 &&./autogen.sh \
 && ./configure --prefix=/usr --disable-documentation \
 && make \
 && make install \
 && apk del .build-deps \
# Runtime dependencies setup
 && apk add --no-cache \
      rng-tools \
      $(scanelf --needed --nobanner /usr/bin/ss-* \
      | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
      | sort -u) \
 && rm -rf ${SSSDIR}

CMD exec ss-manager --manager-address 127.0.0.1:${PORT} -uv