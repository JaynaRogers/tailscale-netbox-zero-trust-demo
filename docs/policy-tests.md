# Tailnet least-privilege policy and tests

This lab uses **grants** (Tailscale's modern policy syntax), rather than legacy ACLs, to allow only a designated identity to reach `tag:netbox-demo` on TCP 22 (OpenSSH) and TCP 443 (Tailscale Serve).

## Apply safely

1. Use the Tailscale admin console to verify that the VM has `tag:netbox-demo`.
2. Open [Access controls](https://login.tailscale.com/admin/acls) and check **all** grants/ACLs. Any remaining `* → *` allow-all policy would undermine the lab's restricted-access claim. Grants are additive.
3. Keep an existing SSH connection open. Substitute the **actual authorized Tailscale login** for `admin@example.com` in [the template](../tailscale/policy.example.hujson), and **merge** its tagOwners/grants/tests with any unrelated entries you intend to keep.
4. Save only after Tailscale's policy validation/tests succeed. Test a **new** SSH connection and new HTTPS browser session from the authorized laptop.
5. Add a second test using a **real second tailnet identity** (replace `unauthorized@example.com`). Ensure it has no other matching grants. Verify both TCP/22 and TCP/443 are denied by policy, not just by a firewall or absent listener.
6. Do not use `sshTests` unless enabling Tailscale SSH; the current demo uses OpenSSH over Tailscale and regular network grants.

## Evidence collected so far

From an approved Windows device, TCP/22 and TCP/443 to the tagged VM returned successful connection results. TCP/8000 was unreachable from the laptop because Docker publishes the NetBox upstream only on `127.0.0.1`.

These are **positive connectivity** and listener-exposure tests. A refusal to connect to TCP/8000 is not, on its own, evidence of a policy deny. The deny-by-identity scenario must be tested separately. A ping response does not prove TCP/80 or TCP/8000 policy exposure.

## Enterprise design notes

- Tag-based destinations are stable across VM rebuilds; grants won't rely on a particular Tailscale IP.
- User-based source means **every device authenticated as that user** can receive access, not exclusively one named laptop. Device-specific restrictions can use appropriate node posture conditions if required.
- App login, RBAC and session management remain NetBox's responsibility. Tailscale encryption and Serve do not replace them.
- Certificate transparency can publicly disclose the `.ts.net` hostname without making the site Internet-accessible.
- **Never publish a production policy** without reviewing its users, tags, advertised routes and other grants.

References: https://tailscale.com/docs/reference/syntax/policy-file and https://tailscale.com/docs/reference/syntax/grants
