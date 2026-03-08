#!/usr/bin/env bash

echo "==> Nix store size:"
df -h /nix/store

echo ""
echo "==> Top 20 largest store paths:"
nix path-info -rS /run/current-system \
  | sort -k2 -n \
  | tail -20 \
  | awk '{printf "%-10s %s\n", $2, $1}'

echo ""
echo "==> System generations:"
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

echo ""
echo "==> Home directory usage:"
du -sh ~/* 2>/dev/null | sort -h
