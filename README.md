# DAppNodePackage-nwaku

## **nwaku**
![avatar](nwaku-avatar-min.png)

### What is nwaku?

`nwaku` is the nim-waku implementation of the Waku protocol suite. 

Waku is the communication layer for Web3. Decentralized communication that scales.

Private. Secure. Runs anywhere.

### How does it work?

The first version of Waku had its origins in the Whisper protocol, with optimizations for scalability and usability. Waku v2 is a complete rewrite. Its relay protocol implements pub/sub over libp2p, and also introduces additional capabilities:

1. Retrieving historical messages for mostly-offline devices.
2. Adaptive nodes, allowing for heterogeneous nodes to contribute.
3. Bandwidth preservation for light nodes.

This makes it ideal for running a p2p protocol on mobile, or in other similarly resource-restricted environments.

[Read the RFCs](https://rfc.vac.dev/spec/10/)

## Package architecture

### Configuration

By default, the following is enabled when the user installs the package:

1. `relay` enabled (default per `nwaku` binary).
2. Secure websockets, with automatic SSL provision using dappnodes HTTPS proxy.

Optionally, through the setup-wizard, the user may enable `filter`, `lightpush` and `store` protocols.

For bleeding edge protocols, such as `RLN`, the user may configure these via the `EXTRA_OPTS` configuration option, that will pass raw flags direct to the `nwaku`.

### Containers

1. `nwaku` - the core package containing the daemon. This container inherits from the upstream found on [docker hub](https://hub.docker.com/r/statusteam/nim-waku) and provides minor modifications, notably including `openssl` and an `entrypoint.sh` script to facilitate automatic configuration based on the user's settings from the package's setup wizard.

### Websockets

By default, dappnode comes installed with the `HTTPS` package, which occupies port `443`, therefore exporting port `443` is not a viable option by default. Fortunately `HTTPS` is an NGINX proxy that is able to be dynamically configured to forward DNS-scoped requests to a nominated package. As such, any external secure websockets connections take the following path:

`Cloud --> NGINX Proxy (HTTPS package, SSL enabled, port 443) --> nwaku (nwaku package, non-SSL, port 8000)`

By configuring an `exposable` port in the dappnode package's configuration, dappnode will automatically:

1. Acquire a dyndns hostname for DNS resolution to it's external IP address.
2. Acquire a wildcard SSL certificate from LetsEncrypt, removing this package's requirement to deal with PKI management, greatly simplifying the structure.
3. Handle SSL termination on NGINX, and forward the encapsulated stream to the nominated destination (nwaku).

While a lot of effort to go to, secure websockets accessed from a site delivered via HTTPS require:

1. A legitimate PKI certificate, otherwise users would have to specifically install and trust a certificate, which significantly hampers UX.
2. All outbound connection requests must be on port 443 (SSL enabled).

By going to these efforts, this package is able to support `js-waku` clients connecting to it from a secure HTTPS site.