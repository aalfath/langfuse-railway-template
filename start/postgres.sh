#!/bin/sh
# Start script for the Postgres service (image postgres).
set -e
def() { if [ -z "$(printenv "$1")" ]; then export "$1=$2"; fi; }
def POSTGRES_USER postgres
def POSTGRES_DB langfuse
# The image sets PGDATA to the volume root, which holds lost+found on Railway,
# so always use a subfolder.
export PGDATA=/var/lib/postgresql/data/pgdata
def TZ UTC
def PGTZ UTC
exec docker-entrypoint.sh postgres
