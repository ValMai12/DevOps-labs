#!/usr/bin/env sh
set -e

echo "Waiting for database..."

until python -c 'import os; import pymysql; pymysql.connect(host=os.getenv("MYWEBAPP_DB_HOST"), user=os.getenv("MYWEBAPP_DB_USER"), password=os.getenv("MYWEBAPP_DB_PASSWORD"), database=os.getenv("MYWEBAPP_DB_NAME"))'; do
  echo "Database is not ready yet..."
  sleep 2
done

echo "Database is ready."

python migrate.py \
  --db-user "$MYWEBAPP_DB_USER" \
  --db-password "$MYWEBAPP_DB_PASSWORD" \
  --db-name "$MYWEBAPP_DB_NAME"

exec gunicorn --bind 0.0.0.0:3000 app:app