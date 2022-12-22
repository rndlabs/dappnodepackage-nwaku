#!/bin/bash

echo "Executing wakunode with the following options:"
echo "  - public IP address: ${_DAPPNODE_GLOBAL_PUBLIC_IP}"
echo "  - domain: ${_DAPPNODE_GLOBAL_DOMAIN}"

env

# Execute passing in public IP address and domain
exec /usr/bin/wakunode --relay=true \
    --filter=true \
    --lightpush=true \
    --store=true \
    --rpc-admin=true \
    --keep-alive=true \
    --max-connections=150 \
    --dns-discovery=true \
    --dns-discovery-url=enrtree://AOGECG2SPND25EEFMAJ5WF3KSGJNSGV356DSTL2YVLLZWIV6SAYBM@prod.nodes.status.im \
    --discv5-discovery=true \
    --discv5-udp-port=9005 \
    --discv5-enr-auto-update=true \
    --log-level=DEBUG \
    --rpc-port=8545 \
    --rpc-address=0.0.0.0 \
    --tcp-port=30304 \
    --metrics-server=true \
    --metrics-server-port=8003 \
    --metrics-server-address=0.0.0.0 \
    --store-message-db-url=sqlite:///data/store.sqlite3 \
    --store-message-retention-policy=time:2592000 \
    --nat=extip:${_DAPPNODE_GLOBAL_PUBLIC_IP} \
    --dns4-domain-name=${_DAPPNODE_GLOBAL_DOMAIN} \
    ${EXTRA_OPTS}
