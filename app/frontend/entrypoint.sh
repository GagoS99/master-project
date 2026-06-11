#!/bin/sh
# Inject API_URL env var into the served HTML at container start.
set -e
API_URL="${API_URL:-/api}"
sed -i "s|window.__API_URL__ \|\| '/api'|'${API_URL}'|" /usr/share/nginx/html/index.html
