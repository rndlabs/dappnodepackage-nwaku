## Network Configuration

If you are running your DAppNode within a network that has a UPnP compatible router, DAppNode will automatically configure your router to forward the appropriate ports to the DAppNode, and on to `nwaku`. Otherwise, to ensure optimal performance of your node, you should configure the following ports to be forwarded from your router's public IP to your DAppNode's internal address:

* TCP/UDP Port 60000 (nwaku P2P)
* UDP Port 9005 (discovery)
* TCP Port 443 (websockets, see [External access](#External-access) below)

### External access

If you wish for your `nwaku` node to provide connectivity for web browsers running `js-waku`, you need to _expose_ the `nwaku` service via the [HTTPs portal settings](http://my.dappnode/#/system/network).

### Monitoring Dashboard

If you have installed [DMS](http://my.dappnode/#/installer/dms.dnp.dappnode.eth), a dashboard is automatically configured allowing you to monitor your `nwaku` node's performance. [Check your node's performance here](http://dms.dappnode/d/nwaku-public-Vcx3GJ2Vk/nwaku-single-node-dashboard?orgId=1&refresh=30s).

## Feedback and useful sites

If you have any questions about nwaku on DAppNode, you may find the package maintainer @mfw78 on both the [Vac Discord](https://discord.gg/j5pGbn7MHZ) and [Dappnode Discord](https://discord.gg/N6q4MVQFGg). If you have any suggestions, bug fixes, PRs etc are welcome on the issue tracker as indicated below.

Sites that may be of interest:

* [Use Waku in Your Application](https://waku.org/platform)
* [Examples](https://examples.waku.org)