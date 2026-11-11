#!/bin/sh
# Start script for the Redis service (image redis). Langfuse needs
# maxmemory-policy noeviction for its BullMQ queues.
set -e
: "${REDIS_PASSWORD:?REDIS_PASSWORD is not set}"
# Railway volumes come with a root-owned lost+found folder, which stops the
# image's entrypoint from handing /data to the redis user.
rm -rf /data/lost+found
exec docker-entrypoint.sh redis-server --requirepass "$REDIS_PASSWORD" \
  --maxmemory-policy noeviction --appendonly yes --dir /data
