# Module 0 — Validation

You are done with Module 0 when you can do ALL of the following from memory, without searching:

- [ ] Tell me whether `sshd` is running and enabled, with one command each.
- [ ] Show me only the *errors* from `sshd` since boot, in one command.
- [ ] List every listening port on this machine and the process that opened it.
- [ ] Show me the systemd unit file for `sshd` (resolved, not the template path).
- [ ] Write a systemd unit from a blank file that runs a script, restarts on failure, depends on the network being up.
- [ ] Explain the difference between `systemctl reload` and `systemctl restart` for a generic unit.
- [ ] Use `journalctl` to find every log line from the last 24 hours that contains the string "Failed".
- [ ] SSH to your VM using a config alias, not a full `-i ~/.ssh/...` command.

If any of these feels uncertain — repeat the exercises that hit it.

## Self-test script

Save this as `~/m0-selftest.sh` on your VM and run it. The output tells you what's still shaky.

```sh
#!/usr/bin/env bash
set -e
echo "1. OS:"; cat /etc/os-release | head -2
echo "2. uptime:"; uptime
echo "3. listeners:"; ss -tlnp 2>/dev/null || sudo ss -tlnp
echo "4. failing units:"; systemctl --failed
echo "5. last 5 sshd lines:"; journalctl -u ssh -n 5 --no-pager 2>/dev/null || journalctl -u sshd -n 5 --no-pager
```

If you couldn't predict the output of each line before running it — review.
