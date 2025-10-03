# Reverse Proxy with SSO

This project contains a reverse proxy, an intrusion prevention service, and a single sign-on application.

The traefik reverse proxy that is used to serve all the web apps in this repo.

Crowdsec is an intrusion prevention software and this stack includes a
bouncer that allows traefik to take action based on decisions made by crowdsec.

Authelia is used to provide SSO functionality to applications that support OAuth or OIDC.
The LLDAP container is the source of truth for all accounts in authelia, and can
be used to provide SSO for apps that only support LDAP.

## Extra info

### Traefik & Crowdsec

The traefik container relies on a file, `traefik/traefik.yml` to provide
some configuration options. The default configuration expects the following settings.

1. An entrypoint named `https` that running on port `443/tcp` and `443/udp` to serve web traffic and http3 traffic.
2. A docker provider to connect to connect to the containers on the `proxy` network.
3. A file provider that provides the middlewares `localonly`,`allowedIPs`, and `crowdsec-bouncer`. `localonly` is used to restrict access to your LAN. `allowedIPs` extends this to include a specific whitelist of IP addresses for friends, organizations, etc. The `crowdsec-bouncer` middleware is used to prevent access to resources from IP addresses banned by crowdsec. This file will be named `traefik/dynamic.yml` on disk.

A sample of both the `traefik/traefik.yml` and `traefik/dynamic.yml` files will be provided in the `examples` directory.

### Authelia

Authelia is a very configurable piece of software, and I can not offer a suitable default configuration for general use.

Please refer to the documentation for Authelia when building out your own `config/configuration.yml` file.

The stack includes `lldap` as the ldap server for authelia to use as its source of truth for users.
You can use the file provider if you wish, but any changes to new or existing users will require restarting the stack
and users will have to reauthenticate. 
The ldap server can also be used for applications that support ldap, but not `authelia`'s OAuth or `traefik`'s forward-headers authentication.

Either way, you should consider a strong password with at least 1 special character, 1 number, 1 lowercase letter, and 1 uppercase letter.
Some services like calibre-web expect users to meet some or all of these requirements and will not work with SSO without them.