# Reverse Proxy

This project contains a reverse proxy.

Traefik is used to serve the web apps in this repository.
As configured, it uses middlewares to allow only specific ip addresses with `allowedIPs` and `localonly`.

The traefik container relies on a file, `traefik/traefik.yml` to provide
some configuration options. The default configuration expects the following settings.

1. An entrypoint named `https` that running on port `443/tcp` and `443/udp` to serve web traffic and http3 traffic.
2. A docker provider to connect to connect to the containers on the `proxy` network.
3. A file provider that provides the middlewares `localonly` and `allowedIPs`. `localonly` is used to restrict access to your LAN. `allowedIPs` extends this to include a specific whitelist of IP addresses for friends, organizations, etc. This file will be named `traefik/dynamic.yml` on disk.

A sample of both the `traefik/traefik.yml` and `traefik/dynamic.yml` files will be provided in the `examples` directory.

Traefik can also be used to proxy TCP or UDP traffic. This allows us to apply middlewares to this traffic for some additional controls.
The example `traefik/dynamic.yml` file will show how one can reuse an ip whitelist between both TCP and HTTP middlewares using yaml anchors.
The middlewares must be applied to a router that points to a service, much like HTTP routes. TLS TCP traffic can use specific HostSNI for matching, otherwise
a default wildcard should be used.
