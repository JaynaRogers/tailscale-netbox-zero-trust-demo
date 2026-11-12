#!/usr/bin/env bash
set -euo pipefail

# Rebuild the lab without touching an existing ~/netbox-docker installation.
# Prerequisites: Ubuntu Linux, Git, Docker Engine with Compose, Tailscale.
# Usage: bash scripts/rebuild.sh prepare
#        NETBOX_SECRETS_REVIEWED=yes bash scripts/rebuild.sh deploy
#        bash scripts/rebuild.sh verify
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="${NETBOX_DOCKER_DIR:-$HOME/netbox-docker-demo-rebuild}"
UPSTREAM_TAG="5.1.1"
NETBOX_IMAGE="v4.7-5.1.1"
OVERRIDE="$ROOT/compose/docker-compose.override.yml"
phase="${1:-prepare}"

check_command() {
  command -v "$1" >/dev/null 2>&1 || { echo "Missing required command: $1" >&2; exit 1; }
}
compose() {
  (cd "$DEST" && sudo env VERSION="$NETBOX_IMAGE" docker compose "$@")
}

case "$phase" in
  prepare)
    check_command git
    check_command docker
    sudo docker compose version >/dev/null
    if [[ -e "$DEST" ]]; then
      echo "Destination already exists: $DEST" >&2
      echo "Refusing to overwrite an existing deployment. Set NETBOX_DOCKER_DIR to a new path." >&2
      exit 1
    fi
    git clone --depth 1 --branch "$UPSTREAM_TAG" https://github.com/netbox-community/netbox-docker.git "$DEST"
    cp "$OVERRIDE" "$DEST/docker-compose.override.yml"
    echo "Prepared pinned upstream netbox-docker $UPSTREAM_TAG at $DEST"
    echo "Before deploying, review and set unique secrets in $DEST/env/*.env"
    echo "Follow docs/rebuild.md. Secrets are never generated or written to GitHub by this script."
    ;;
  deploy)
    check_command docker
    check_command curl
    sudo docker compose version >/dev/null
    [[ -f "$DEST/docker-compose.yml" && -f "$DEST/docker-compose.override.yml" ]] || {
      echo "Run prepare first and verify the destination directory." >&2; exit 1;
    }
    [[ "${NETBOX_SECRETS_REVIEWED:-}" == "yes" ]] || {
      echo "Refusing to deploy: review unique env secrets, then set NETBOX_SECRETS_REVIEWED=yes." >&2; exit 1;
    }
    compose config --quiet
    compose pull
    compose up -d
    echo "Waiting for local NetBox HTTP response (up to 10 minutes)..."
    ready=0
    for _ in {1..60}; do
      if curl --silent --show-error --max-time 3 --output /dev/null --fail http://127.0.0.1:8000/login/ 2>/dev/null; then
        ready=1
        break
      fi
      sleep 10
    done
    compose ps
    if [[ "$ready" != 1 ]]; then
      echo "NetBox did not respond successfully. Check: sudo docker compose logs netbox" >&2
      exit 1
    fi
    echo "NetBox responds locally. Create an admin with:"
    echo "  cd \"$DEST\" && sudo env VERSION=$NETBOX_IMAGE docker compose exec netbox /opt/netbox/netbox/manage.py createsuperuser"
    echo "After enrolling Tailscale and enabling HTTPS certificates, run: bash tailscale/serve.sh"
    ;;
  verify)
    check_command docker
    check_command curl
    [[ -f "$DEST/docker-compose.yml" ]] || { echo "Deployment directory missing" >&2; exit 1; }
    compose config --quiet
    compose ps
    response="$(curl --silent --show-error --max-time 8 --output /dev/null --write-out '%{http_code}' http://127.0.0.1:8000/login/)"
    [[ "$response" == "200" || "$response" == "302" ]] || {
      echo "Unexpected NetBox HTTP status: $response" >&2; exit 1;
    }
    echo "NetBox loopback HTTP: $response"
    if command -v tailscale >/dev/null 2>&1; then
      tailscale status
      tailscale serve status
    else
      echo "Tailscale CLI unavailable; verify Tailscale enrollment and Serve manually."
    fi
    echo "Manual checks: OCI ingress, tailnet access grants, HTTPS login, second-identity denial."
    ;;
  *)
    echo "Usage: bash scripts/rebuild.sh {prepare|deploy|verify}" >&2
    exit 2
    ;;
esac
