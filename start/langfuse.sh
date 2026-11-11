#!/bin/sh
# Start script for the Langfuse web and worker services (images langfuse/langfuse
# and langfuse/langfuse-worker). Usage: langfuse.sh web|worker
# Fixed settings get a default here; any variable set on the Railway service wins.
set -e
ROLE="${1:?usage: langfuse.sh web|worker}"
def() { if [ -z "$(printenv "$1")" ]; then export "$1=$2"; fi; }

# Listen on IPv4 and IPv6 (Railway's private network uses IPv6).
export HOSTNAME=::

# ClickHouse (service "ClickHouse", user set by its own start script).
def CLICKHOUSE_USER clickhouse
def CLICKHOUSE_DB default
def CLICKHOUSE_CLUSTER_ENABLED false

# Redis (BullMQ queues and cache).
def REDIS_PORT 6379

# S3: one Railway bucket holds raw events, media and batch exports under
# separate prefixes. The template sets the LANGFUSE_S3_EVENT_UPLOAD_* values;
# media and export settings are copied from them unless set explicitly.
def LANGFUSE_S3_EVENT_UPLOAD_PREFIX events/
def LANGFUSE_S3_EVENT_UPLOAD_FORCE_PATH_STYLE false
def LANGFUSE_S3_MEDIA_UPLOAD_BUCKET "$LANGFUSE_S3_EVENT_UPLOAD_BUCKET"
def LANGFUSE_S3_MEDIA_UPLOAD_REGION "$LANGFUSE_S3_EVENT_UPLOAD_REGION"
def LANGFUSE_S3_MEDIA_UPLOAD_ENDPOINT "$LANGFUSE_S3_EVENT_UPLOAD_ENDPOINT"
def LANGFUSE_S3_MEDIA_UPLOAD_ACCESS_KEY_ID "$LANGFUSE_S3_EVENT_UPLOAD_ACCESS_KEY_ID"
def LANGFUSE_S3_MEDIA_UPLOAD_SECRET_ACCESS_KEY "$LANGFUSE_S3_EVENT_UPLOAD_SECRET_ACCESS_KEY"
def LANGFUSE_S3_MEDIA_UPLOAD_FORCE_PATH_STYLE "$LANGFUSE_S3_EVENT_UPLOAD_FORCE_PATH_STYLE"
def LANGFUSE_S3_MEDIA_UPLOAD_PREFIX media/
def LANGFUSE_S3_BATCH_EXPORT_ENABLED true
def LANGFUSE_S3_BATCH_EXPORT_BUCKET "$LANGFUSE_S3_EVENT_UPLOAD_BUCKET"
def LANGFUSE_S3_BATCH_EXPORT_REGION "$LANGFUSE_S3_EVENT_UPLOAD_REGION"
def LANGFUSE_S3_BATCH_EXPORT_ENDPOINT "$LANGFUSE_S3_EVENT_UPLOAD_ENDPOINT"
def LANGFUSE_S3_BATCH_EXPORT_EXTERNAL_ENDPOINT "$LANGFUSE_S3_EVENT_UPLOAD_ENDPOINT"
def LANGFUSE_S3_BATCH_EXPORT_ACCESS_KEY_ID "$LANGFUSE_S3_EVENT_UPLOAD_ACCESS_KEY_ID"
def LANGFUSE_S3_BATCH_EXPORT_SECRET_ACCESS_KEY "$LANGFUSE_S3_EVENT_UPLOAD_SECRET_ACCESS_KEY"
def LANGFUSE_S3_BATCH_EXPORT_FORCE_PATH_STYLE "$LANGFUSE_S3_EVENT_UPLOAD_FORCE_PATH_STYLE"
def LANGFUSE_S3_BATCH_EXPORT_PREFIX exports/

case "$ROLE" in
  web)
    def PORT 3000
    # Nobody can sign up on a fresh public URL: the first user comes from the
    # LANGFUSE_INIT_* variables. Set AUTH_DISABLE_SIGNUP=false to let invited
    # teammates create accounts.
    def AUTH_DISABLE_SIGNUP true
    def LANGFUSE_DISABLE_SIGNUP_ONBOARDING true
    def LANGFUSE_INIT_ORG_ID default-org
    def LANGFUSE_INIT_ORG_NAME "My Organization"
    def LANGFUSE_INIT_PROJECT_ID default-project
    def LANGFUSE_INIT_PROJECT_NAME "My Project"
    def LANGFUSE_INIT_USER_NAME Admin
    exec dumb-init -- ./web/entrypoint.sh node ./web/server.js --keepAliveTimeout 110000
    ;;
  worker)
    def PORT 3030
    exec dumb-init -- ./worker/entrypoint.sh node worker/dist/index.js
    ;;
  *) echo "unknown role: $ROLE" >&2; exit 1 ;;
esac
