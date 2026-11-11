#!/bin/sh
# Prints the Railway start command for each service of the Langfuse template.
# Every service runs a pinned upstream image; its start command writes this
# repo's start script into the container and runs it, so nothing is built.
# Re-run after changing a script and paste the new command into that service.
set -eu
cd "$(dirname "$0")/.."
cmd() { # cmd <file> [args] [prefix]
  printf '%s/bin/sh -c "echo %s | base64 -d > /tmp/start.sh && exec /bin/sh /tmp/start.sh%s"' \
    "${3:-}" "$(base64 -w0 < "$1")" "${2:+ $2}"
}
line() { printf '\n# %s\n%s\n' "$1" "$2"; }
line "Langfuse (langfuse/langfuse)"               "$(cmd start/langfuse.sh web)"
line "Langfuse-Worker (langfuse/langfuse-worker)" "$(cmd start/langfuse.sh worker)"
line "ClickHouse (clickhouse/clickhouse-server)"  "$(cmd start/clickhouse.sh)"
line "Postgres (postgres)"                        "$(cmd start/postgres.sh)"
line "Redis (redis)"                              "$(cmd start/redis.sh)"
