#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
PID_DIR="$ROOT/.run"
for id in A B; do
  pid_file="$PID_DIR/backend-$id.pid"
  if [ -f "$pid_file" ]; then
    pid=$(cat "$pid_file")
    if kill -0 "$pid" 2>/dev/null; then
      kill "$pid"
      echo "Stopped Backend $id (pid $pid)"
    else
      echo "Backend $id was not running"
    fi
    rm -f "$pid_file"
  else
    echo "No pid file for Backend $id"
  fi
done
