# Threat model and security controls

| Concern | Design control | Required test |
| --- | --- | --- |
| Public NetBox access | Compose binds only localhost; Serve is tailnet-only | OCI ingress audit and external denied connection |
| Public SSH scanning | OCI public TCP/22 rule removed after testing private SSH | Public SSH denied, SSH over tailnet succeeds |
| Unauthorized tailnet members | Restrictive Tailscale grants/ACLs needed | Negative test with a separate identity/device |
| Unauthorized NetBox modifications | NetBox authentication and app-level roles | Anonymous login redirect and read-only role test |
| Credentials in Git | Env files, tokens, private keys excluded | Review commits and scan for secrets |
| Accidentally published HTTPS | Never enable Funnel | `tailscale serve status` shows tailnet only |

**Limitations:** Public certificate transparency logs disclose the Tailscale HTTPS *hostname*, not access to the private service. The internal Serve-to-NetBox hop is loopback HTTP, not end-to-end container TLS. No claim is made that the existing tailnet ACLs are least-privilege until they have been configured and tested with real identities. This repository includes no active tailnet policy or customer data.

The VM's OCI security list and any attached NSGs must be inspected independently. A local bind does not replace firewall governance, software patching, application credentials, or backup procedures.
