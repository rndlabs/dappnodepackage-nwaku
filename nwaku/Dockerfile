ARG UPSTREAM_VERSION

FROM wakuorg/nwaku:${UPSTREAM_VERSION}

RUN apk add --no-cache bash openssl
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

EXPOSE 60000 8545 9005

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
