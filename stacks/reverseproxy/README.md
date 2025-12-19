# Reverse Proxy with SSO

This project contains a reverse proxy, an intrusion prevention service, and a single sign-on application.

The traefik reverse proxy that is used to serve all the web apps in this repo.

Crowdsec is an intrusion prevention software and this stack includes a
bouncer that allows traefik to take action based on decisions made by crowdsec.

Authelia is used to provide SSO functionality to applications that support OAuth or OIDC.
The LLDAP container is the source of truth for all accounts in authelia, and can
be used to provide SSO for apps that only support LDAP.

Vector is a tool that can transform and filter data. It is used here to filter out geoip blocked and private ranges
in traefik's access log. This is done to prevent those logs from reaching crowdsec and using up the free plan's quota on
addresses that are outside your defined region.

This requires a logging structure like this:
- traefik puts logs into `/var/log/traefik`.
- vector reads from `/var/log/traefik`, filters and outputs to `/var/log/crowdsec/traefik`.
- crowdsec read from `/var/log/traefik`. From what I understand, this can not be changed, so we must map the bind mount accordingly.
So it would be `${data:-.}/logs/crowdsec:/var/log/:ro`.


## Extra info

### Traefik & Crowdsec

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

### Authelia

Authelia is a very configurable piece of software, and I can not offer a suitable default configuration for general use.

Please refer to the documentation for Authelia when building out your own `config/configuration.yml` file.

The stack includes `lldap` as the ldap server for authelia to use as its source of truth for users.
You can use the file provider if you wish, but any changes to new or existing users will require restarting the stack
and users will have to reauthenticate.
The ldap server can also be used for applications that support ldap, but not `authelia`'s OAuth or `traefik`'s forward-headers authentication.

Either way, you should consider a strong password with at least 1 special character, 1 number, 1 lowercase letter, and 1 uppercase letter.
Some services like calibre-web expect users to meet some or all of these requirements and will not work with SSO without them.

### Geoip Filter

This stack integrates a container that allows traefik to use MaxMind GeoIP data to filter traffic from specific countries or regions.

This integration requires a free maxmind account that can be setup [here](https://www.maxmind.com/en/geolite2/signup).
You will need to create a license key and provide your account id when setting up the stack.

You may change the http response code given when a user is geo-blocked. I have this set to code 418 which is unused in normal HTTP operations.
This allows me to ignore logging traffic geo-blocked, which lowers my usage for crowdsec's free plan.

### Vector

Vector will allow us to filter out specific log items from traefik's access logs.

I use this to filter private ip information and status code 418 before it hits crowdsec.

An example configuration file will be provided in the examples folder. This file must be put in the ${data}/vector folder to be read by vector.
