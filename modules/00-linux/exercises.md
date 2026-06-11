# Module 0 — Exercises

You will do these on a Linux VM. Options (pick one):

- **A.** UTM / VirtualBox / Multipass with Ubuntu 22.04 or Debian 12.
- **B.** Docker container in `--privileged` mode running a systemd-enabled image (`jrei/systemd-ubuntu:22.04`).
- **C.** WSL2 (Ubuntu) on Windows — note WSL has quirks with systemd; works in recent Ubuntu releases.

> If you skip this module because "I know Linux," validate yourself against `validation.md` first. If any item is shaky, do the module.

## Exercise 1 — Inspect the system

1. Identify the OS, kernel, total RAM, and number of CPU cores. Note the commands you used.
2. List all listening TCP ports and the process owning each.
3. List the 10 largest files under `/var/log/`.

## Exercise 2 — Drive systemd

1. Find the status of `ssh` (or `sshd`). Is it active? Enabled at boot?
2. Restart it. Confirm it came back.
3. View logs for that service for the last 1 hour.
4. View *only* error-level logs for that service since the last boot.

## Exercise 3 — Write a unit

Create a systemd unit named `hellotick.service` that:

- Runs `/usr/local/bin/hellotick.sh` on start.
- Restarts on failure with a 5-second delay.
- Logs to journald.
- Starts after the network is online.

The script should write the current timestamp to `/var/log/hellotick.log` once every 10 seconds for 5 minutes, then exit 0.

Tasks:
1. Write the script. Make it executable.
2. Write the unit file at `/etc/systemd/system/hellotick.service`.
3. Reload systemd, start the service, confirm via `systemctl status` and `journalctl -u hellotick`.
4. Reboot (or stop+start) and confirm the unit comes back if you `enable` it.

## Exercise 4 — Break and fix

1. Edit the unit to point at a non-existent script path. Reload, restart.
2. Use `journalctl` and `systemctl status` to identify the failure.
3. Fix it without rebooting.

## Exercise 5 — Networking basics

1. From inside the VM, use `curl -v` to fetch `http://example.com`. Identify the DNS lookup, TCP connect, TLS handshake (if HTTPS), and HTTP exchange in the verbose output.
2. Use `dig` (or `nslookup`) to find the A records for `example.com`. Then resolve them via `/etc/hosts` instead — temporarily override one. Test. Revert.
3. Use `ss -tlnp` to list listeners. Start a tiny HTTP server (`python3 -m http.server 9000 &`) and confirm it appears.

## Exercise 6 — SSH ergonomics

1. Generate an Ed25519 SSH key (no passphrase is fine for this lab; use a passphrase if you'll reuse the key).
2. Add a host alias to `~/.ssh/config` so `ssh devvm` connects to your VM with the right user and key.
3. Use `scp` (or `rsync`) to copy a file to the VM.

## Stretch (optional, useful)

- Read `man systemd.service` end to end once. (15 min.)
- Write a timer unit (`hellotick.timer`) that triggers `hellotick.service` every 5 minutes.
- Add a `Restart=on-failure` and a `RestartSec=` directive; deliberately make the script `exit 1` and observe restart behavior.
