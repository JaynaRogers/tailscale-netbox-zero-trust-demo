# Access validation record — 2026-11-12

## Scope and prerequisites

The NetBox demo runs on an Oracle Cloud Ubuntu ARM64 VM using OpenSSH over Tailscale and Tailscale Serve for tailnet-only HTTPS. The NetBox container is published exclusively to VM loopback at `127.0.0.1:8000`. A Tailscale grant authorizes the primary user identity to reach the VM's `tag:netbox-demo` on TCP/22 and TCP/443. The default `* → *` allow-all grant was reported removed.

The tests below were conducted interactively by the operator, with results reported during setup; this record does **not** contain machine-generated test artifacts or assertions that a second test's failure was proven by packet traces. Avoid committing public IPs, personal email addresses or private URLs in screenshots or logs.

## Observed access matrix

| Client / identity | Destination | Test | Result | Interpretation |
| --- | --- | --- | --- | --- |
| Windows laptop, authorized identity | Demo VM | `Test-NetConnection <tailnet-ip> -Port 22` | `TcpTestSucceeded: True` | Authorized OpenSSH transport reachable |
| Windows laptop, authorized identity | Demo VM | `Test-NetConnection <tailnet-ip> -Port 443` | `TcpTestSucceeded: True` | Authorized HTTPS listener reachable |
| Windows laptop, authorized identity | Demo VM | `Test-NetConnection <tailnet-ip> -Port 8000` | `TcpTestSucceeded: False` | NetBox HTTP isn't published on the tailnet IP; **not an independent policy-deny test** |
| Mac, second invited Tailscale identity | Demo VM | `nc -G 5 -vz <tailnet-ip> 22` | `Operation timed out` | Consistent with restricted grants; root cause not proven |
| Mac, second invited Tailscale identity | Demo VM | `nc -G 5 -vz <tailnet-ip> 443` | `Operation timed out` | Consistent with restricted grants; root cause not proven |
| Mac, second invited Tailscale identity | Local Tailscale client | `/Applications/Tailscale.app/Contents/MacOS/Tailscale status` | Reported local macOS node and Tailscale address | Confirms local client is running and identifies its logged-in identity; does not independently confirm target visibility or policy denial |
| Authorized Windows laptop | NetBox URL | HTTPS browser login | Loaded and login succeeded (reported) | Serve and application functioning end to end |

The Mac was installed with Tailscale and the second account invitation was accepted. The operator supplied the actual macOS `nc` output, which reports `Operation timed out` on both ports. The Tailscale app's bundled CLI returned a local node entry with an assigned tailnet IP and user identity; its hostname and login are intentionally omitted from this public record. This one-line status result does not independently show the destination node or prove why connections timed out. For stronger evidence, verify the active tailnet and test the intended source/destination using the policy editor's built-in grant tests. Connection timeouts can have causes other than a policy denial.

## Security boundary conclusions

- Authorized connectivity on TCP/22 and TCP/443 is directly supported by Windows results.
- Unauthorized Mac failures are **consistent with** restricted grants, but exact cause has not been independently established.
- TCP/8000 fails because the application is published to `127.0.0.1`, irrespective of policy.
- ICMP echo/ping outcomes are not proxies for TCP authorization.
- NetBox local authentication still governs application privileges.
- Access is permitted by the authorized **user identity**, so additional devices using that identity may also be permitted; it is not a per-laptop restriction.

## Repeatable demonstration

On the authorized Windows device:

```powershell
Test-NetConnection <netbox-tailnet-ip> -Port 22
Test-NetConnection <netbox-tailnet-ip> -Port 443
Test-NetConnection <netbox-tailnet-ip> -Port 8000
```

On an unauthorized, separately enrolled Mac:

```bash
/Applications/Tailscale.app/Contents/MacOS/Tailscale status
nc -G 5 -vz <netbox-tailnet-ip> 22
nc -G 5 -vz <netbox-tailnet-ip> 443
```

Expected: Windows 22 and 443 succeed; Windows 8000 fails; Mac 22 and 443 fail. Confirm that the Mac is connected to the same tailnet and that no alternate path, endpoint or local firewall condition explains the failure.

**Never put SSH keys, NetBox passwords, API tokens or Tailscale auth keys into test artifacts.**
