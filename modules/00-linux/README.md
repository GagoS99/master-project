# Module 0 — Linux Fundamentals Refresher

**Time:** ~0.5 week (4-6 hours)
**Free-tier risk:** none (entirely local / VM)

## Why this module exists

You will spend the rest of the bootcamp logging into a Linux box, reading logs, and debugging systemd units. If your fingers don't know `journalctl`, `ss`, `systemctl status`, and `cat /etc/os-release` by reflex, every later module triples in difficulty.

This module is not "learn Linux." It is "rebuild the muscle for the seven commands you'll use 200 times in the next 6 weeks."

## Learning objectives

By the end you should be able to, without looking anything up:

1. Use `systemctl` to start, stop, enable, and inspect a service unit.
2. Use `journalctl` to read logs scoped by unit, time, and priority.
3. Use `ss` (or `netstat`) to list listening ports and matching processes.
4. Use `ps`, `top`, `htop` and explain CPU/memory columns.
5. Read `/etc/os-release`, `/proc/cpuinfo`, `/proc/meminfo`.
6. Write a simple systemd unit file and load it with `systemctl daemon-reload`.
7. Use `ssh`, `scp`, and `~/.ssh/config` host aliases.
8. Understand the difference between `/etc/`, `/var/`, `/usr/local/`, `/opt/`.

## What you read

Concept refresh (skim only if rusty):
- https://systemd.io/ — start here, particularly the Quick Start.
- https://wiki.archlinux.org/title/Systemd — best per-feature reference, even on non-Arch.
- https://man7.org/linux/man-pages/man1/journalctl.1.html

## What you do

See `exercises.md`.

## How you know you're done

See `validation.md`.

## Working with the AI in this module

The AI's behavior in this module is in `AGENT.md`. tl;dr: it will refuse to write commands for you. It will ask you what you tried.
