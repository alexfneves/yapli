#!/usr/bin/env bash
set -euo pipefail

echo "Generating file list..."

WATCH_FILES=$(git ls-files)

if [[ -z "$WATCH_FILES" ]]; then
  echo "No matching Git-tracked source files found."
  exit 1
fi

# Extract unique directories from Git-tracked files
WATCH_DIRS=$(echo "$WATCH_FILES" | xargs -n1 dirname | sort -u)

echo "Watching directories:"
echo "$WATCH_DIRS"

echo "Waiting for changes..."

# Main loop
while true; do
  inotifywait \
    -q \
    -r \
    -e close_write,create,move,delete \
    $WATCH_DIRS >/dev/null

  echo "🔁 Change detected, running build..."
  hot-reload || true
done
