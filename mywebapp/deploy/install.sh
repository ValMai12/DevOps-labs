#!/usr/bin/env bash
set -e

APP_NAME="mywebapp"
APP_DIR="/opt/mywebapp"
DB_NAME="mywebapp"
DB_USER="mywebapp"
DB_PASSWORD="mypassword"
APP_PORT="3000"
GRADEBOOK_NUMBER="12"

echo "Installing packages..."
apt update
apt install -y python3 python3-venv python3-pip mariadb-server nginx sudo

echo "Creating users..."
id -u student >/dev/null 2>&1 || useradd -m -s /bin/bash student
id -u teacher >/dev/null 2>&1 || useradd -m -s /bin/bash teacher
id -u operator >/dev/null 2>&1 || useradd -m -s /bin/bash operator
id -u app >/dev/null 2>&1 || useradd --system --home "$APP_DIR" --shell /usr/sbin/nologin app

echo "Setting default passwords..."
echo "student:12345678" | chpasswd
echo "teacher:12345678" | chpasswd
echo "operator:12345678" | chpasswd

chage -d 0 teacher
chage -d 0 operator

usermod -aG sudo student
usermod -aG sudo teacher

echo "Creating gradebook file..."
echo "$GRADEBOOK_NUMBER" > /home/student/gradebook
chown student:student /home/student/gradebook
chmod 644 /home/student/gradebook

echo "Creating application directory..."
mkdir -p "$APP_DIR"
cp -r . "$APP_DIR"
chown -R app:app "$APP_DIR"

echo "Creating Python virtual environment..."
python3 -m venv "$APP_DIR/venv"
"$APP_DIR/venv/bin/pip" install -r "$APP_DIR/requirements.txt"

echo "Configuring MariaDB..."
systemctl enable mariadb
systemctl start mariadb

mysql -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
mysql -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';"
mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

echo "Installing systemd service..."
cp "$APP_DIR/deploy/mywebapp.service" /etc/systemd/system/mywebapp.service
cp "$APP_DIR/deploy/mywebapp.socket" /etc/systemd/system/mywebapp.socket

systemctl daemon-reload
systemctl enable mywebapp.socket
systemctl start mywebapp.socket
systemctl restart mywebapp

echo "Configuring nginx..."
cp "$APP_DIR/deploy/mywebapp.nginx" /etc/nginx/sites-available/mywebapp
ln -sf /etc/nginx/sites-available/mywebapp /etc/nginx/sites-enabled/mywebapp
rm -f /etc/nginx/sites-enabled/default

nginx -t
systemctl enable nginx
systemctl restart nginx

echo "Configuring operator sudo permissions..."
cat > /etc/sudoers.d/operator-mywebapp <<EOF
operator ALL=(root) NOPASSWD: /bin/systemctl start mywebapp
operator ALL=(root) NOPASSWD: /bin/systemctl stop mywebapp
operator ALL=(root) NOPASSWD: /bin/systemctl restart mywebapp
operator ALL=(root) NOPASSWD: /bin/systemctl status mywebapp
operator ALL=(root) NOPASSWD: /bin/systemctl reload nginx
EOF

chmod 440 /etc/sudoers.d/operator-mywebapp

echo "Blocking default ubuntu user if exists..."
if id -u ubuntu >/dev/null 2>&1; then
    usermod -L ubuntu
fi

echo "Deployment completed successfully."