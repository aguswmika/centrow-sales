#!/usr/bin/env bash

WATCH_DIR="$(pwd)"

echo "Watching Flutter project for changes..."

find "$WATCH_DIR" -type f \
  ! -path "*/.git/*" \
  ! -path "*/build/*" \
| entr -r bash -c 'kill -SIGUSR1 $(pgrep -f "[f]lutter_tool.*run")'