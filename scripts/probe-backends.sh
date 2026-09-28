#!/bin/sh
set -eu
for port in 3001 3002; do
  for path in / /api/status; do
    echo "--- http://127.0.0.1:$port$path"
    curl -sS -i "http://127.0.0.1:$port$path"
    printf '\n'
  done
done
