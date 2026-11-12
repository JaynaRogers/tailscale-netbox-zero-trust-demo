# Rebuild the NetBox + Tailscale demo

This is a **guided, repeatable deployment**, not a fully unattended rebuild. It does not create Oracle Cloud resources, enroll devices into a tailnet, modify Tailscale grants, or handle credentials automatically.

## Requirements

- Ubuntu Linux VM (tested deployment was Oracle Cloud ARM64 / Ubuntu 22.04)
- Docker Engine with `docker compose`, Git, curl, and sudo rights
- Own tailnet and permissions to enroll the VM, configure grants, and enable HTTPS certificates
- A Windows or other client with Tailscale
- OCI inbound firewall restrictions reviewed separately

The script deliberately defaults to `~/netbox-docker-demo-rebuild` so it **does not alter the original live installation**. The exact upstream Docker project release is `5.1.1`, paired with NetBox image `v4.7-5.1.1`. Version changes must be tested together.

## 1. Prepare the pinned files

Clone this demo repo to the Linux VM, then:

```bash
bash scripts/rebuild.sh prepare
```

This clones upstream NetBox Docker at tag `5.1.1` into a new directory and installs the localhost-only override. If the destination already exists, the script refuses to overwrite it.

## 2. Configure application secrets manually

Review upstream `env/*.env` as instructed by the official NetBox Docker documentation. Generate strong, distinct secrets locally for PostgreSQL, Valkey/Redis (including cache), NetBox's SECRET_KEY and API-token pepper settings as required by that upstream release. Make matching values consistent across the upstream env files. Never store them in this public repo, issue comments, console logs, screenshots, or CI variables unnecessarily.

Before starting, verify the upstream env files are complete, file permissions are appropriate, and no sample/default credentials remain. The script **does not certify** that secrets are correct.

## 3. Deploy containers

Only after reviewing the secrets:

```bash
NETBOX_SECRETS_REVIEWED=yes bash scripts/rebuild.sh deploy
```

The script validates Compose, pulls matching images, brings up the stack, and waits for a local NetBox login response. It does not publish a public HTTP listener.

Create the admin interactively:

```bash
cd ~/netbox-docker-demo-rebuild
sudo env VERSION=v4.7-5.1.1 docker compose exec netbox /opt/netbox/netbox/manage.py createsuperuser
```

## 4. Join Tailscale and enable Serve

Install and enroll Tailscale using [official Linux instructions](https://tailscale.com/docs/install/linux) and your own account. In the Tailscale admin console, enable HTTPS certificates, tag the machine with your appropriate demo tag, and apply restricted grants. Do **not** paste example identities unchanged into production policy.

```bash
bash tailscale/serve.sh
```

This proxies the local app over private tailnet HTTPS `:443`. **Do not enable Funnel.** Confirm `tailscale serve status` reports tailnet-only.

Verify SSH access using the Tailscale IP and an SSH key **before** removing the OCI public TCP/22 bootstrap rule. Inspect OCI NSG/security-list rules to ensure no public NetBox or SSH ingress remains.

## 5. Validate and document evidence

```bash
bash scripts/rebuild.sh verify
```

On an approved client, validate HTTPS NetBox login and TCP/22 and TCP/443 reachability. Test an enrolled second identity that lacks the destination grant and document command output. A timeout by itself does **not** prove which control blocked the connection. Capture Tailscale policy test results for stronger evidence.

## What this automation does not prove

GitHub Actions checks syntax and configuration shape; it does not boot a new cloud VM or start a full integration stack. The original demonstration worked interactively. **A fresh-from-zero redeployment using these scripts has not yet been performed or verified.** Reproducibility remains a proposed workflow until that test is completed.
