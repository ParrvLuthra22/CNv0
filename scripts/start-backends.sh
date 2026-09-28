#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
PID_DIR="$ROOT/.run"
mkdir -p "$PID_DIR"
start_one() {
  id=$1
  port=$2
  pid_file="$PID_DIR/backend-$id.pid"
  log_file="$PID_DIR/backend-$id.log"
  if [ -f "$pid_file" ] && kill -0 "$(cat "$pid_file")" 2>/dev/null; then
    echo "Backend $id already running (pid $(cat "$pid_file"))"
    return
  fi
  (cd "$ROOT/backend" && BACKEND_ID="$id" PORT="$port" nohup node server.js >>"$log_file" 2>&1 & echo $! >"$pid_file")
  echo "Started Backend $id on 0.0.0.0:$port (pid $(cat "$pid_file"))"
}
start_one A 3001
start_one B 3002
