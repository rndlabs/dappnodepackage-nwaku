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

# If DNS_DISCOVERY_URL is not set, use NETWORK to determine which DNS discovery URL to use
# NETWORK may be wakuv2.prod, wakuv2.test, status.prod or status.test
if [ -z "${DNS_DISCOVERY_URL}" ]; then
    case "${NETWORK}" in
        wakuv2.prod)
            export WAKUNODE2_DNS_DISCOVERY_URL="enrtree://AOGECG2SPND25EEFMAJ5WF3KSGJNSGV356DSTL2YVLLZWIV6SAYBM@prod.waku.nodes.status.im"
            ;;
        wakuv2.test)
            export WAKUNODE2_DNS_DISCOVERY_URL="enrtree://AOGECG2SPND25EEFMAJ5WF3KSGJNSGV356DSTL2YVLLZWIV6SAYBM@test.waku.nodes.status.im"
            ;;
        status.prod)
            export WAKUNODE2_DNS_DISCOVERY_URL="enrtree://AOGECG2SPND25EEFMAJ5WF3KSGJNSGV356DSTL2YVLLZWIV6SAYBM@prod.nodes.status.im"
            ;;
        status.test)
            export WAKUNODE2_DNS_DISCOVERY_URL="enrtree://AOGECG2SPND25EEFMAJ5WF3KSGJNSGV356DSTL2YVLLZWIV6SAYBM@test.nodes.status.im"
            ;;
        *)
            echo "NETWORK must be set to wakuv2.prod, wakuv2.test, status.prod or status.test"
            exit 1
            ;;
    esac
else
    export WAKUNODE2_DNS_DISCOVERY_URL=${DNS_DISCOVERY_URL}
fi

# Execute passing in public IP address and domain
exec /usr/bin/wakunode --relay=true \
    --filter=true \
    --lightpush=true \
    --store=true \
    --rpc-admin=true \
    --keep-alive=true \
    --max-connections=${MAX_CONNECTIONS:-150} \
    --dns-discovery=true \
    --discv5-discovery=true \
    --discv5-udp-port=9005 \
    --discv5-enr-auto-update=True \
    --log-level=${LOG_LEVEL:-DEBUG} \
    --rpc-port=8545 \
    --rpc-address=0.0.0.0 \
    --tcp-port=60000 \
    --metrics-server=True \
    --metrics-server-port=9090 \
    --metrics-server-address=0.0.0.0 \
    --store-message-db-url:sqlite:///data/store.sqlite3 \
    --store-message-retention-policy:time:${STORE_MESSAGE_RETENTION_POLICY:-2592000} \
    --nat=extip:${_DAPPNODE_GLOBAL_PUBLIC_IP} \
    --dns4-domain-name=nwaku.${_DAPPNODE_GLOBAL_DOMAIN} \
    ${EXTRA_OPTS}
