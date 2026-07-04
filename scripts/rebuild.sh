#rebuild.sh
#!/usr/bin/env bash
set -e

cd ~/nixos-config || { echo "ERROR: ~/nixos-config not found"; exit 1; }

# Stage all changes
git add -A

git diff --stat
# Commit with a message (use provided arg or default)
COMMIT_MSG="${1:-update nixos config}"
git commit -m "$COMMIT_MSG" || echo "Nothing to commit"

# Push to remote
git push

# Rebuild
sudo nixos-rebuild switch --flake .#titan --show-trace
