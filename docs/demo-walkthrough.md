# Live demo runbook

1. Present the architecture and trust boundaries: OCI internet edge, tailnet, NetBox authorization.
2. Show Oracle security list: no inbound public TCP/22, TCP/443, or TCP/8000.
3. From a connected laptop, demonstrate SSH to the VM's Tailscale 100.x address with an SSH private key.
4. Show `sudo docker compose ps` and `curl -I http://127.0.0.1:8000` on the VM.
5. Show `tailscale serve status`: tailnet-only HTTPS port 443.
6. Open the private `.ts.net` URL from a tailnet client; sign into NetBox.
7. **Before claiming policy enforcement**, demonstrate denied access from an unauthorized identity/device. Confirm external public-IP attempts fail.
8. Discuss trade-offs and failure cases: control-plane outages vs existing data paths, certificate management, incorrect tailnet grants, first-run DB migrations and health checks, updates, device revocation, and backups.

Key architectural decision: use native Tailscale Serve instead of adding a public reverse proxy. Keep the HTTP upstream on VM loopback and separate NetBox application authentication from network access.
