# Purpose

This repo contains docker compose files to be used in deploying a stack of containers on a server using the [Komodo](https://komo.do) service.

The stacks/test folder represents the general format that all additional stacks should follow:

1. The path for a stack should be `stacks/{name_of_stack}`
2. The docker-compose file should be named `compose.yaml`
3. Generally, I prefer `snake_case` for folder and file names.
4. Including an `example.env` is recommended if the stack uses environment variables.

Many of these stacks depend on an external network called `proxy`. This is used to connect services that provide an http website to
a reverse proxy. This network must be created before the stacks can run.

You can run this command to create the network:
`docker network create -d bridge proxy`
