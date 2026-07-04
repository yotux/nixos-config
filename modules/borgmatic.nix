{ config, pkgs, ... }:

{
  # sops: let nmurray read the borg passphrase
  sops.secrets.borg_passphrase = {
    owner = "nmurray";
  };

  services.borgmatic = {
    enable = true;

    settings = {
      archive_name_format = "titan-borgmatic-{now:%Y-%m-%dT%H:%M:%S}";
      repositories = [
        {
          path = "ssh://gme4v0e9@gme4v0e9.repo.borgbase.com/./repo";
          label = "borgbase";
        }
      ];

      ssh_command = "ssh -i /home/nmurray/.ssh/borgbase_ed25519 -o IdentitiesOnly=yes";

      source_directories = [
        "/home/nmurray"
      ];

      encryption_passcommand = "cat /run/secrets/borg_passphrase";

      exclude_patterns = [
        # CRITICAL: sops decryption identity
        "/home/nmurray/.config/sops/age/keys.txt"
        # Dedicated backup key (don't store inside the repo it unlocks)
        "/home/nmurray/.ssh/borgbase_ed25519"

        # Caches / regenerable
        "/home/nmurray/.cache"
        "sh:/home/nmurray/**/node_modules"
        "sh:/home/nmurray/**/__pycache__"
        "sh:/home/nmurray/**/.direnv"

        # Browser cache
        "sh:/home/nmurray/.config/vivaldi/**/*Cache*"
        "sh:/home/nmurray/.config/vivaldi/**/WebStorage"
        "sh:/home/nmurray/.config/vivaldi/**/Service Worker"
        "sh:/home/nmurray/.config/vivaldi/**/IndexedDB"
        "sh:/home/nmurray/.config/vivaldi/**/GPUCache"
        "/home/nmurray/.config/librewolf"

        # Regenerable app/system state
        "/home/nmurray/.local/share/containers"
        "/home/nmurray/.local/share/baloo"
        "/home/nmurray/.local/share/klipper"
        "/home/nmurray/.local/share/Trash"
        "/home/nmurray/.local/share/flatpak"

        # Regenerable binaries / AppImage
        "/home/nmurray/virt/squashfs-root"
        "/home/nmurray/virt/Crashpad"
        "/home/nmurray/virt/bin"
        "/home/nmurray/Manager-x86_64.AppImage"

        # User dirs to skip
        "/home/nmurray/Downloads"
        "/home/nmurray/Desktop"
        "/home/nmurray/Music"
        "/home/nmurray/Videos"
        "/home/nmurray/Templates"
        "/home/nmurray/Public"
        "/home/nmurray/Pictures"
      ];

      exclude_if_present = [
        ".nobackup"
        "CACHEDIR.TAG"
      ];

      keep_daily = 7;
      keep_weekly = 4;
      keep_monthly = 6;
      keep_yearly = 1;

      retries = 5;
      retry_wait = 5;
    };
  };

  # Schedule: 3x/day, laptop-tuned with catch-up on wake
  systemd.timers.borgmatic.timerConfig = {
    OnCalendar = "*-*-* 09,15,21:00:00";
    Persistent = true;
    RandomizedDelaySec = "5m";
  };

  systemd.services.borgmatic.serviceConfig = {
    User = "nmurray";
    Group = "users";
  };
}
