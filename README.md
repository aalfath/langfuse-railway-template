# Langfuse on Railway: start scripts

Start scripts for the Langfuse Railway template. Every service runs a pinned
upstream image from Docker Hub; nothing is built. Each service's Railway start
command writes one of these scripts into the container (base64) and runs it.

| Service | Image | Script |
|---|---|---|
| Langfuse (web, public) | `langfuse/langfuse:4.78.0` | `start/langfuse.sh web` |
| Langfuse-Worker | `langfuse/langfuse-worker:4.78.0` | `start/langfuse.sh worker` |
| ClickHouse | `clickhouse/clickhouse-server:26.3.62.3` | `start/clickhouse.sh` |
| Postgres | `postgres:17.11` | `start/postgres.sh` |
| Redis | `redis:8.10.3` | `start/redis.sh` |

The scripts give fixed settings a default (`def NAME value`); any variable set
on the Railway service wins. So the template's own variables are only service
references, generated secrets and ports.

- `start/langfuse.sh`: listens on IPv4 and IPv6, uses one Railway bucket for
  events, media and batch exports (`events/`, `media/`, `exports/` prefixes),
  closes sign-up (`AUTH_DISABLE_SIGNUP=true`) and sets the names used by the
  `LANGFUSE_INIT_*` first-run setup.
- `start/clickhouse.sh`: logs to stdout only and drops the larger system log
  tables.
- `start/redis.sh`: `maxmemory-policy noeviction` (needed by Langfuse's queues)
  and AOF persistence.
- `start/postgres.sh`: keeps data in a subfolder of the volume.

`scripts/start-commands.sh` prints the start command for every service. Re-run
it after changing a script and paste the result into the service settings.

Upstream: [langfuse/langfuse](https://github.com/langfuse/langfuse),
[self-hosting docs](https://langfuse.com/self-hosting).
