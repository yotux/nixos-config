#!/usr/bin/env bash
set -e

cd ~/nixos-config

# Stage all changes
git add -A

# Commit with a message (use provided arg or default)
COMMIT_MSG="${1:-update nixos config}"
git commit -m "$COMMIT_MSG" || echo "Nothing to commit"

# Push to remote
git push

# Rebuild
sudo nixos-rebuild switch --flake .#titan
