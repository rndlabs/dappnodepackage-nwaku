#!/bin/bash

# If DNS_DISCOVERY_URL is not set, use NETWORK to determine which DNS discovery URL to use
# NETWORK may be wakuv2.prod, wakuv2.test, status.prod or status.test
if [ -z "${DNS_DISCOVERY_URL}" ]; then
    case "${NETWORK}" in
        wakuv2.prod)
            export WAKUNODE2_DNS_DISCOVERY_URL="enrtree://ANEDLO25QVUGJOUTQFRYKWX6P4Z4GKVESBMHML7DZ6YK4LGS5FC5O@prod.wakuv2.nodes.status.im"
            ;;
        wakuv2.test)
            export WAKUNODE2_DNS_DISCOVERY_URL="enrtree://AO47IDOLBKH72HIZZOXQP6NMRESAN7CHYWIBNXDXWRJRZWLODKII6@test.wakuv2.nodes.status.im"
            ;;
        status.prod)
            export WAKUNODE2_DNS_DISCOVERY_URL="enrtree://AL65EKLJAUXKKPG43HVTML5EFFWEZ7L4LOKTLZCLJASG4DSESQZEC@prod.status.nodes.status.im"
            ;;
        status.test)
            export WAKUNODE2_DNS_DISCOVERY_URL="enrtree://AIO6LUM3IVWCU2KCPBBI6FEH2W42IGK3ASCZHZGG5TIXUR56OGQUO@test.status.nodes.status.im"
            ;;
        *)
            echo "NETWORK must be set to wakuv2.prod, wakuv2.test, status.prod or status.test"
            exit 1
            ;;
    esac
else
    export WAKUNODE2_DNS_DISCOVERY_URL=${DNS_DISCOVERY_URL}
fi

# If PRIVACY is set to paranoid, disable the agent string
if [ "${PRIVACY}" = "paranoid" ]; then
    unset WAKUNODE2_AGENT_STRING
else
    # If RANDOMIZE_ADDRESS is set to false use the same address every time. 
    # If identity.pem does not exist, generate a new one
    if [ "${RANDOMIZE_ADDRESS}" = "false" ]; then
        if [ ! -f /data/identity.pem ]; then
            echo "Generating new identity"
            # Generate new identity using openssl
            /usr/bin/openssl ecparam -name secp256k1 -genkey -noout -out /data/identity.pem
        fi
        # Extract 32 byte private key from identity.pem
        _PRIVATE_KEY=$(cat /data/identity.pem | /usr/bin/openssl ec -text -noout | grep priv -A 3 | tail -n +2 | tr -d '\n[:space:]:' | xxd -r -p | xxd -p -c 32)
        # Set environment variable WAKUNODE2_NODEKEY to private key
        export WAKUNODE2_NODEKEY=${_PRIVATE_KEY}
    fi
fi

# If EXPERIMENTAL_FEATURES is set to true
if [ "${EXPERIMENTAL_FEATURES}" = "true" ]; then
    # If WAKUNODE2_LIGHTPUSH is set to true, set to 1
    if [ "${WAKUNODE2_LIGHTPUSH}" = "true" ]; then
        export WAKUNODE2_LIGHTPUSH=1
    else
        unset WAKUNODE2_LIGHTPUSH
    fi

    # If WAKUNODE2_FILTER is set to true, set to 1
    if [ "${WAKUNODE2_FILTER}" = "true" ]; then
        export WAKUNODE2_FILTER=1
    else
        unset WAKUNODE2_FILTER
    fi

    # If WAKUNODE2_STORE is set to true, set to 1
    if [ "${WAKUNODE2_STORE}" = "true" ]; then
        export WAKUNODE2_STORE=1
    else
        # unset all environment variables start withing WAKUNODE2_STORE prefix
        unset WAKUNODE2_STORE WAKUNODE2_STORE_MESSAGE_RETENTION_POLICY WAKUNODE2_STORE_MESSAGE_DB_URL
    fi
else
    # unset all environment variables start withing WAKUNODE2 prefix excluding WAKUNODE2_DNS_DISCOVERY_URL
    # if EXPERIMENTAL_FEATURES is set to false
    unset WAKUNODE2_LIGHTPUSH WAKUNODE2_FILTER 
    unset WAKUNODE2_STORE WAKUNODE2_STORE_MESSAGE_RETENTION_POLICY WAKUNODE2_STORE_MESSAGE_DB_URL
fi

# Execute passing in public IP address and domain
exec /usr/bin/wakunode --relay=true \
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
    --nat=extip:${_DAPPNODE_GLOBAL_PUBLIC_IP} \
    --dns4-domain-name=nwaku.${_DAPPNODE_GLOBAL_DOMAIN} \
    --ext-multiaddr:/dns4/nwaku.${_DAPPNODE_GLOBAL_DOMAIN}/tcp/443/wss \
    --websocket-support=true \
    ${EXTRA_OPTS}
