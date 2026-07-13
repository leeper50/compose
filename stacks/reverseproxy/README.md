# Reverse Proxy with SSO

This project contains a reverse proxy and a single sign-on application.

PocketID is used to provide SSO functionality to applications that support OAuth or OIDC.

Traefik is used to serve the web apps in this repository.
As configured, it uses middlewares to allow only specific ip addresses with `allowedIPs` and `localonly`.
Further restrictions to routes can use the `tinyauth` forward authentication middleware.

## Extra info

### PocketID & Tinyauth

PocketID is a very simple and secure OpenID and OAuth provider that uses passkeys instead of passwords.
Tinyauth can restrict access to routes using PocketID's access controls.

The official guide on how to integrate tinyauth with PocketID is available [here](https://tinyauth.app/docs/guides/pocket-id/).

PocketID maintains a list of example configurations for applications [here](https://pocket-id.org/docs/client-examples).

Apps you may want to integrate that are presenting in this repository include:
- [Bookstack](https://pocket-id.org/docs/client-examples/bookstack) from the `docs` stack.
- [Forgejo](https://pocket-id.org/docs/client-examples/forgejo) from the `forgejo` stack.
- [FreshRSS](https://pocket-id.org/docs/client-examples/freshrss) from the `website` stack.
- [Gitea](https://pocket-id.org/docs/client-examples/gitea) from the `gitea` stack.
- [Grafana](https://pocket-id.org/docs/client-examples/grafana) from the `docs` stack.
- [Immich](https://pocket-id.org/docs/client-examples/immich) from the `media` stack.
- [Jellyfin](https://pocket-id.org/docs/client-examples/jellyfin) from the `media` stack.
- [N8N (Formerly Node-RED)](https://pocket-id.org/docs/client-examples/node-red) from the `n8n` stack.
- [Nextcloud](https://pocket-id.org/docs/client-examples/nextcloud) from the `nextcloud` stack.
- [Paperless-ngx](https://pocket-id.org/docs/client-examples/paperless-ngx) from the `paperlessngx` stack.
- [Vaulwarden](https://pocket-id.org/docs/client-examples/vaultwarden) from the `website` stack.


### Traefik

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
