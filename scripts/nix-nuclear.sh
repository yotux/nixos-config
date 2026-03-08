#!/usr/bin/env bash
set -e

echo "WARNING: This will delete ALL old NixOS generations."
read -p "Are you sure? (y/N): " confirm
[[ "$confirm" == "y" ]] || exit 1

echo "==> Removing all old generations..."
sudo nix-collect-garbage -d

echo "==> Optimising store..."
sudo nix store optimise

echo "==> Rebuilding boot menu..."
sudo /run/current-system/bin/switch-to-configuration boot

echo "==> Done. Store size:"
df -h /nix/store
