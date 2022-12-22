ARG UPSTREAM_VERSION
FROM statusteam/nim-waku:${UPSTREAM_VERSION}
EXPOSE 30303 60000 8545 9000

RUN apk add --no-cache bash
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]