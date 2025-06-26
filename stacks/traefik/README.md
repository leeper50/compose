# Traefik & Crowdsec
This stack contains the traefik reverse proxy that is used to serve all the web apps in this repo.

It also contains the crowdsec intrusion prevention software and a
bouncer for traefik to take action based on decisions made by crowdsec.

## Extra info
The traefik container relies on a file, `traefik/traefik.yml` to provide
some configuration options. The default configuration expects the following settings.
1. An entrypoint named `https` that running on port `443/tcp` to serve web traffic.
2. A docker provider to connect to connect to the containers on the `proxy` network.
3. A file provider that provides the middlewares `localonly`,`goodbois`, and `crowdsec-bouncer`. `localonly` is used to restrict access to a LAN. `goodbois` extends this to include a specific whitelist of IP addresses. The `crowdsec-bouncer` middleware is used to prevent access to resources from IP addresses banned by crowdsec. This file will be named `traefik/dynamic.yml` on disk.

A sample of both the `traefik/traefik.yml` and `traefik/dynamic.yml` files will be provided in the `examples` directory.

## ! Important !
This solution depends on the `authelia` stack for functionality. If the `authelia` is not running, this stack will not work!