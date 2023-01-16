#!/bin/bash

# If RANDOMIZE_ADDRESS is set to false, use the same address every time
# If identity.pem does not exist, generate a new one
if [ "${RANDOMIZE_ADDRESS}" = "false" ]; then
    if [ ! -f /data/identity.pem ]; then
        echo "Generating new identity"
        # Generate new identity using openssl
        /usr/bin/openssl ecparam -name secp256k1 -genkey -noout -out /data/identity.pem
    fi
    # Extract 32 byte private key from identity.pem
    _PRIVATE_KEY=$(cat /data/identity.pem | /usr/bin/openssl ec -text -noout | grep priv -A 3 | tail -n +2 | tr -d '\n[:space:]:' | xxd -r -p | xxd -p -c 32)
    # Set environment variable WAKUNODEV2_NODEKEY to private key
    export WAKUNODE2_NODEKEY=${_PRIVATE_KEY}
fi


# Execute passing in public IP address and domain
exec /usr/bin/wakunode --filter \
    --lightpush \
    --store \
    --rpc-admin \
    --keep-alive \
    --max-connections:${MAX_CONNECTIONS:-150} \
    --dns-discovery \
    --dns-discovery-url=${DNS_DISCOVERY_URL} \
    --discv5-discovery \
    --discv5-udp-port:9005 \
    --discv5-enr-auto-update \
    --log-level:${LOG_LEVEL:-DEBUG} \
    --rpc-port:8545 \
    --rpc-address:0.0.0.0 \
    --tcp-port:60000 \
    --metrics-server \
    --metrics-server-port=9090 \
    --metrics-server-address=0.0.0.0 \
    --store-message-db-url:sqlite:///data/store.sqlite3 \
    --store-message-retention-policy:time:${STORE_MESSAGE_RETENTION_POLICY:-2592000} \
    --nat=extip:${_DAPPNODE_GLOBAL_PUBLIC_IP} \
    --dns4-domain-name=nwaku.${_DAPPNODE_GLOBAL_DOMAIN} \
    ${EXTRA_OPTS}
