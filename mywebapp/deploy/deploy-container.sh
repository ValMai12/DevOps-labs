#!/usr/bin/env bash
set -e

IMAGE="$1"

APP_NAME="mywebapp"
NETWORK_NAME="mywebapp_network"
DB_CONTAINER="mywebapp-db"
WEB_CONTAINER="mywebapp-web"

DB_NAME="mywebapp"
DB_USER="mywebapp"
DB_PASSWORD="mypassword"
DB_ROOT_PASSWORD="rootpassword"

if [ -z "$IMAGE" ]; then
  echo "Image argument is required"
  exit 1
fi

docker network create "$NETWORK_NAME" || true

docker rm -f "$WEB_CONTAINER" || true

if ! docker ps -a --format '{{.Names}}' | grep -q "^${DB_CONTAINER}$"; then
  docker run -d \
    --name "$DB_CONTAINER" \
    --restart unless-stopped \
    --network "$NETWORK_NAME" \
    -e MARIADB_DATABASE="$DB_NAME" \
    -e MARIADB_USER="$DB_USER" \
    -e MARIADB_PASSWORD="$DB_PASSWORD" \
    -e MARIADB_ROOT_PASSWORD="$DB_ROOT_PASSWORD" \
    -v mywebapp_db_data:/var/lib/mysql \
    mariadb:11
else
  docker start "$DB_CONTAINER"
fi

docker pull "$IMAGE"

docker run -d \
  --name "$WEB_CONTAINER" \
  --restart unless-stopped \
  --network "$NETWORK_NAME" \
  -p 3000:3000 \
  -e MYWEBAPP_DB_HOST="$DB_CONTAINER" \
  -e MYWEBAPP_DB_USER="$DB_USER" \
  -e MYWEBAPP_DB_PASSWORD="$DB_PASSWORD" \
  -e MYWEBAPP_DB_NAME="$DB_NAME" \
  "$IMAGE"

sudo tee /etc/nginx/sites-available/mywebapp >/dev/null <<'EOF'
server {
    listen 80;
    server_name _;

    access_log /var/log/nginx/mywebapp_access.log;
    error_log /var/log/nginx/mywebapp_error.log;

    location / {
        proxy_pass http://127.0.0.1:3000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /notes {
        proxy_pass http://127.0.0.1:3000/notes;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /notes/ {
        proxy_pass http://127.0.0.1:3000/notes/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /health/ {
        return 404;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/mywebapp /etc/nginx/sites-enabled/mywebapp
sudo rm -f /etc/nginx/sites-enabled/default

sudo nginx -t
sudo systemctl restart nginx

sudo cp /opt/mywebapp/mywebapp-container.service /etc/systemd/system/mywebapp-container.service
sudo systemctl daemon-reload
sudo systemctl enable mywebapp-container.service

echo "Deployment completed successfully."