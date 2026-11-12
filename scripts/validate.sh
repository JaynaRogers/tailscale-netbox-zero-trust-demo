#!/usr/bin/env bash
set -euo pipefail
cd "${NETBOX_DOCKER_DIR:-$HOME/netbox-docker}"
echo "Docker Compose:"
sudo docker compose ps
echo "Local NetBox HTTP response:"
curl --fail --silent --show-error --location --output /dev/null --write-out '%{http_code}\n' http://127.0.0.1:8000/login/
echo "Tailscale:"
tailscale status
tailscale serve status
echo "Manual checks still required: validate OCI public ingress restrictions, tailnet policy, HTTPS login, and unauthorized-device denial."
