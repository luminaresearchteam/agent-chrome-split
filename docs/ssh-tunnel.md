# Cloud agents: reach the debug port through an SSH tunnel

Chrome's remote-debugging port listens on `127.0.0.1` only. That is a safety feature:
anyone who can reach the port fully controls every logged-in session in that profile.

An agent running on the same computer just connects to `http://127.0.0.1:<PORT>`.
A cloud agent cannot, and you should **not** "fix" that by exposing the port.

## Recommended: private network + SSH local forward

1. Put the computer and the agent's machine on a private network (for example Tailscale, WireGuard, or a VPN).
2. Enable SSH on the computer (macOS: System Settings → General → Sharing → Remote Login; Linux: `sshd`).
   Allow only key-based login.
3. From the agent's machine:

```bash
ssh -N -L 9335:127.0.0.1:9335 <user>@<private-host-or-ip>
```

4. The agent now talks to `http://127.0.0.1:9335` on its own side; traffic is encrypted end to end.

## Never

- Never start Chrome with `--remote-debugging-address=0.0.0.0` or forward the port to the public internet.
- Never share the tunnel with other users or services.

## Fallback

If a tunnel is not possible, let the agent use the normal desktop window (bring it to the front) while you watch.
