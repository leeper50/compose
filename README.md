# Purpose

This repo contains standardized docker compose stacks to be deployed using [Komodo](https://komo.do).

The heart of this project is the `swarm/reverseproxy` folder.
It provides:
- Traefik for declarative https routing for web facing services.
- PocketID & TinyAuth for OAUTH, OIDC, and LDAP support for universal login and route protection.
- A docker socket proxy so Traefik can read container labels without direct access to the docker socket.

All web facing stacks depend on an external network called `proxy`.
This is used to connect services that provide an http website to traefik.
The reverse proxy stack also depends on an external network called `socket-proxy`.
These networks must be created before the stacks can run.
They need to be attachable overlay networks so that both swarm stacks and plain compose stacks can join them.
You can run these commands to create the networks:
- `docker network create -d overlay --attachable proxy`
- `docker network create -d overlay --attachable socket-proxy`

Stacks are split into two folders:
- `swarm` contains stacks deployed to the docker swarm.
- `stacks` contains stacks deployed with plain docker compose, for services that need features swarm does not support, such as host devices.

The stacks will always have this layout:
1. The path for stack is `swarm/{name_of_stack}` or `stacks/{name_of_stack}`
2. The docker compose file is named `compose.yaml`
3. An `example.env` is included and should be changed to match your environment.
4. A README.md file may be included if the stack requires additional work. Some examples include
  - Post-install steps
  - Providing an initial configuration file
  - Setting up folder with specific permissions

Image versions are pinned in each `compose.yaml` and kept up to date by [Renovate](https://docs.renovatebot.com), configured in `renovate.json`.
