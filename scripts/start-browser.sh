#!/bin/ash

if [ -z "$DISPLAY" ]; then
  echo "DISPLAY not set. Connect with ssh -X"
  exit 1
fi

if ! pgrep -x "openbox" > /dev/null; then
  echo "Starting Openbox..."
  openbox &
  sleep 1
fi

echo "Launching Falkon..."
falkon --no-sandbox &

