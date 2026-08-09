#!/usr/bin/env bash
set -e

# How many recent system/user generations to KEEP
KEEP=${1:-5}

echo "==> Keeping the last $KEEP system generations, deleting the rest..."
sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +"$KEEP"

echo "==> Keeping the last $KEEP user profile generations, deleting the rest..."
nix-env --delete-generations +"$KEEP"

echo "==> Running garbage collection..."
sudo nix-collect-garbage

echo "==> Optimising nix store..."
sudo nix store optimise

echo "==> Rebuilding boot menu (removes stale boot entries)..."
sudo /run/current-system/bin/switch-to-configuration boot

echo "==> Vacuuming systemd journal to 500 MiB max..."
journalctl --vacuum-size=500M

echo "==> Removing logs >30 days old..."
find /var/log -type f -mtime +30 -delete

echo "==> Done. Current store size:"
df -h /nix/store

echo "==> Remaining system generations:"
sudo nix-env --profile /nix/var/nix/profiles/system --list-generations
