# infra

Shared local development infrastructure, managed with Docker Compose. One repo
to run the databases, cache, message broker, and identity provider that all your
projects share — instead of scattered `docker run` commands.

## Services

| Service   | Image                          | Host port      | Profile |
|-----------|--------------------------------|----------------|---------|
| PostgreSQL| `postgres:18.4`                | 5432           | `db`    |
| MySQL     | `mysql:9.7.1`                  | 3306           | `db`    |
| Redis     | `redis:8.8.0`                  | 6379           | `cache` |
| RabbitMQ  | `rabbitmq:4.3.2-management`    | 5672, 15672    | `mq`    |
| Authentik | `goauthentik/server:2026.5.3`  | 9000, 9443     | `auth`  |

Authentik runs a `server` + `worker` pair. Since 2025.10 it no longer uses Redis
(cache/outpost/websocket moved to Postgres), so it depends only on PostgreSQL.

## Quick start

```bash
cp .env.example .env     # then fill secrets (see commands in the file)
make up                  # start everything
make ps                  # check status
```

Start a subset by profile:

```bash
make db        # postgres + mysql
make cache     # redis
make auth      # authentik
# or directly:
docker compose --profile db --profile cache up -d
```

Authentik first-run setup: open <http://localhost:9000/if/flow/initial-setup/>.

## Connecting from other projects

**Option 1 — shared network (recommended).** Containers reach services by name:

```yaml
# in your project's compose file
services:
  api:
    environment:
      DB_HOST: postgres        # service name on infra-net
      REDIS_HOST: redis
    networks: [infra-net]
networks:
  infra-net:
    external: true             # provided by this repo (run `make up` first)
```

**Option 2 — host ports.** From the host or non-networked containers use
`localhost:5432` (host) / `host.docker.internal:5432` (container).

Credentials live in `.env`: superuser `postgres`, MySQL `root`, RabbitMQ `admin`.

## Adding a service

Copy a block in `compose.yaml`, give it a `container_name`, a `profiles:` tag
(add `all`), a named volume, a healthcheck, and `networks: [infra-net]`. Add any
secrets to `.env` + `.env.example`. That's it.

## Adding a project database

- **Postgres:** drop a `*.sql`/`*.sh` file in `init/postgres/` (runs on first
  init only). Example pattern in `01-create-authentik-database.sh`.
- **MySQL:** add an init dir + mount to `/docker-entrypoint-initdb.d`, or create
  manually: `docker exec -it infra-mysql mysql -uroot -p`.

> Init scripts only run when a volume is **empty**. To re-run them you must
> recreate the volume (`make nuke` destroys ALL data).

## Common commands

```bash
make up / down / restart / ps      # lifecycle
make logs s=postgres               # tail one service
make pull                          # update to pinned images
make nuke                          # DESTROY containers + all data volumes
```

## Notes

- Image versions are pinned (no `latest`) for reproducibility. Bump in
  `compose.yaml` + `make pull` to upgrade.
- `restart: unless-stopped` — services come back after reboot.
- `.env` is gitignored; never commit real secrets.
