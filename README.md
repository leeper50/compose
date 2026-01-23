# Purpose

This repo contains standardized docker compose stacks to be deployed using [Komodo](https://komo.do).

The heart of this project is the `stacks/reverseproxy` folder.
It provides:
- Traefik for declarative https routing for web facing services.
- PocketID & TinyAuth for OAUTH, OIDC, and LDAP support for universal login and route protection.
- Crowdsec, a MaxMind(TM) geoipfilter, and Vector for intrusion prevention and security.

All web facing stacks depend on an external network called `proxy`. 
This is used to connect services that provide an http website to traefik.
This network must be created before the stacks can run.
You can run this command to create the network `docker network create -d bridge proxy`.

Addional stacks are provided as deploy-able services in the `stacks` folder that users may want.
The stacks will always have this layout:
1. The path for stack is `stacks/{name_of_stack}`
2. The docker compose file is named `compose.yaml`
3. An `example.env` is included and should be changed to match your environment.
4. A README.md file may be included if the stack requires additional work. Some examples include
  - Post-install steps
  - Providing an initial configuration file
  - Setting up folder with specific permissions

Enrollment of services into uptimekuma's monitoring system is provided by `autokuma` from the `docs` stack.
Containers have labels attached that use autokuma's snippets to setup monitors for containers and web endpoints,
along with integration with `ntfy` for downtime notifications.
