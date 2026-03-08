#!/usr/bin/env bash
set -e

echo "==> Collecting garbage..."
sudo nix-collect-garbage --delete-older-than 30d

echo "==> Cleaning user profile..."
nix-collect-garbage --delete-older-than 30d

echo "==> Optimising nix store..."
sudo nix store optimise

# 5. Vacuum systemd journal to 500 MiB max
journalctl --vacuum-size=500M

# 6. Remove logs >30 days old
find /var/log -type f -mtime +30 -delete

echo "==> Done. Current store size:"
df -h /nix/store
