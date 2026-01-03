# Reverse Proxy with SSO

This project contains a reverse proxy, an intrusion prevention service, and a single sign-on application.

PocketID is used to provide SSO functionality to applications that support OAuth or OIDC.

Crowdsec is an intrusion prevention software and this stack includes a
bouncer that allows traefik to take action based on decisions made by crowdsec.

The geoipfilter container uses a MaxMind database to match incoming ip addresses with a country code.
This is used to filter out traffic that you may not want from areas where you do not expect to serve users.

Traefik is used to serve the web apps in this repository. As configured, it uses various middlewares to limit traffic by
filter with `geoipfilter`, allow only specific ip addresses with `allowedIPs` and `localonly`, and restrict access
to routes with `tinyauth` forward authentication middleware.

Vector is a tool that can transform and filter data. It is used here to filter out geoip blocked and private ranges
in traefik's access log. This is done to prevent those logs from reaching crowdsec and using up the free plan's quota on
addresses that are outside your defined region.

This requires a logging structure like this:
- traefik puts logs into `/var/log/traefik`.
- vector reads from `/var/log/traefik`, filters and outputs to `/var/log/crowdsec/traefik`.
- crowdsec read from `/var/log/traefik`. From what I understand, this can not be changed, so we must map the bind mount accordingly.
So it would be `${data:-.}/logs/crowdsec:/var/log/:ro`.


## Extra info

### Crowdsec

Crowdsec's has two post-install steps. It must accept traefik's crowdsec bouncer, and optionally, it can connect to crowdsec's web console.

#### Connecting Traefik

To connect traefik to crowdsec, we must run the following command to generate a crowdsec api key.
You may rename traefik-bouncer.
`docker exec crowdsec cscli bouncers add traefik-bouncer`
This will provide a value for the crowdsecLapiKey variable in the `examples/dynamic.yml` file
```yaml
http:
  middlewares:
    crowdsec:
      plugin:
        bouncer:
          ...other settings
          crowdsecLapiKey: <crowdsec_api_key_here>
```
The `dynamic.yml` is hot-reloaded by traefik so you do not need to restart any services.

#### Connecting Crowdsec Console
To enroll the crowdsec engine to Crowdsec's web console, you must have an account follow these steps:
1. Go to the engines page [here](https://app.crowdsec.net/security-engines).
2. Click the enroll command to generate a command that looks like this `sudo cscli console enroll <a_very_long_id>`.
3. Run this command on your docker host `docker exec crowdsec cscli console enroll <a_very_long_id>`.
4. Check that the engine is showing up on the dashboard and is providng metrics.
5. Restart the crowdsec container. `docker restart crowdsec`

### Geoip Filter

This stack integrates a container that allows traefik to use MaxMind GeoIP data to filter traffic from specific countries or regions.

This integration requires a free maxmind account that can be setup [here](https://www.maxmind.com/en/geolite2/signup).
You will need to create a license key and provide your account id when setting up the stack.

You may change the http response code given when a user is geo-blocked. I have this set to code 418 which is unused in normal HTTP operations.
This allows me to ignore logging traffic geo-blocked, which lowers my usage for crowdsec's free plan.

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
3. A file provider that provides the middlewares `localonly`,`allowedIPs`, and `crowdsec`. `localonly` is used to restrict access to your LAN. `allowedIPs` extends this to include a specific whitelist of IP addresses for friends, organizations, etc. The `crowdsec` middleware is used to prevent access to resources from IP addresses banned by crowdsec. This file will be named `traefik/dynamic.yml` on disk.

A sample of both the `traefik/traefik.yml` and `traefik/dynamic.yml` files will be provided in the `examples` directory.

Traefik can also be used to proxy TCP or UDP traffic. This allows us to apply middlewares to this traffic for some additional controls.
The example `traefik/dynamic.yml` file will show how one can reuse an ip whitelist between both TCP and HTTP middlewares using yaml anchors.
The middlewares must be applied to a router that points to a service, much like HTTP routes. TLS TCP traffic can use specific HostSNI for matching, otherwise
a default wildcard should be used.

### Vector

Vector will allow us to filter out specific log items from traefik's access logs.

I use this to filter private ip information and status code 418 before it hits crowdsec.

An example configuration file will be provided in the examples folder. This file must be put in the ${data}/vector folder to be read by vector.
