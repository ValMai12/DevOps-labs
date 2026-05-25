#!/usr/bin/env bash
set -e

IMAGE="$1"

APP_DIR="/opt/mywebapp"
CONTAINER_NAME="mywebapp-web"

mkdir -p "$APP_DIR"

docker pull "$IMAGE"

docker rm -f "$CONTAINER_NAME" || true

docker run -d \
  --name "$CONTAINER_NAME" \
  --restart unless-stopped \
  -p 3000:3000 \
  -e MYWEBAPP_DB_HOST="127.0.0.1" \
  -e MYWEBAPP_DB_USER="mywebapp" \
  -e MYWEBAPP_DB_PASSWORD="mypassword" \
  -e MYWEBAPP_DB_NAME="mywebapp" \
  "$IMAGE"