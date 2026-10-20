# Paperless-ngx Stack

Paperless-ngx needs a Postgres database and a Valkey (or Redis) server.
These are not part of this stack and are expected to run outside of the swarm, for example as NixOS managed services.
Set `db_host`, `db_port`, and `redis_url` in your env file to point at them.

## Postgres

Create a database and a user that owns it, matching `db_name`, `db_user`, and `db_pass`.

Postgres must accept connections from the swarm.
1. It must listen on an address the swarm nodes can reach, not only `localhost`.
2. `pg_hba.conf` must allow the paperless user to connect from the address the containers use, with password (`scram-sha-256`) authentication.
3. Port `5432/tcp` must be open in the host firewall.

When connecting to a service on a swarm node, containers usually appear to come from that node's `docker_gwbridge` subnet, which is often `172.18.0.0/16`.
Check it with `docker network inspect docker_gwbridge`.

## Valkey

Valkey must listen on an address the swarm nodes can reach, and port `6379/tcp` must be open in the host firewall.
Set a password, since Valkey has no access controls other than that and the bind address.

`redis_url` uses the format `redis://:<password>@<host>:<port>`.
Leave out `:<password>@` if Valkey has no password.

## Migrating from the old containers

Earlier versions of this stack ran Postgres and Valkey as containers, storing data under `/mnt/docker/paperless/db` and `/mnt/docker/paperless/valkey`.
Valkey only holds the task queue, so it does not need to be migrated.

To move the database:
1. Stop paperless so nothing writes to the database.
2. Dump it from the old container with `pg_dump -U paperless -Fc paperless > paperless.dump`.
   If the old container is already gone, start a temporary `postgres:16` container with `/mnt/docker/paperless/db` mounted at `/var/lib/postgresql/data` and dump from that.
   The version must stay at 16, since that is what created the data directory.
3. Restore it into the new server with `pg_restore -U paperless -d paperless --no-owner paperless.dump`.
4. Redeploy the stack with the new env settings.
