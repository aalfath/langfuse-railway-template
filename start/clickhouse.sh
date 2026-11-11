#!/bin/sh
# Start script for the ClickHouse service (image clickhouse/clickhouse-server).
set -e
def() { if [ -z "$(printenv "$1")" ]; then export "$1=$2"; fi; }
def CLICKHOUSE_USER clickhouse
def CLICKHOUSE_DB default
: "${CLICKHOUSE_PASSWORD:?CLICKHOUSE_PASSWORD is not set}"
# Railway volumes come with a root-owned lost+found folder.
rm -rf /var/lib/clickhouse/lost+found
# Keep server logs on stdout only (the log folder is not on the volume), and
# turn down the internal system log tables so a small instance stays small.
mkdir -p /etc/clickhouse-server/config.d
cat > /etc/clickhouse-server/config.d/zz-railway.xml <<'XML'
<clickhouse>
  <logger>
    <level>warning</level>
    <console>1</console>
    <log remove="remove"/>
    <errorlog remove="remove"/>
  </logger>
  <trace_log remove="remove"/>
  <text_log remove="remove"/>
  <metric_log remove="remove"/>
  <asynchronous_metric_log remove="remove"/>
  <latency_log remove="remove"/>
  <query_metric_log remove="remove"/>
</clickhouse>
XML
exec /entrypoint.sh
