#!/usr/bin/env bash
set -euo pipefail
# Tailscale HTTPS certificates must first be enabled in the tailnet DNS settings.
# Serve is private to the tailnet. Never enable Funnel for this demo.
sudo tailscale serve --bg --https=443 http://127.0.0.1:8000
tailscale serve status
