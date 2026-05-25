#!/usr/bin/env bash
set -e

curl -f http://localhost/

curl -f http://localhost/notes

curl -f http://localhost/health/alive

echo "Verification successful!"