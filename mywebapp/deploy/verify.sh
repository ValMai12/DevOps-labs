#!/usr/bin/env bash
set -e

curl -f http://localhost/

curl -f http://localhost/notes

curl -f http://127.0.0.1:3000/health/alive

if curl -fs http://localhost/health/alive; then
  echo "ERROR: /health/alive should not be available through nginx"
  exit 1
else
  echo "Nginx correctly hides /health/alive"
fi

echo "Verification successful!"