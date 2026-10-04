{ config, pkgs, ... }:

{
  # sops: let nmurray read the borg passphrase
  sops.secrets.borg_passphrase = {
    owner = "nmurray";
    sopsFile = ../secrets/titan/borg.yaml;
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
      encryption_passcommand = "cat /run/secrets/borg_passphrase";

      source_directories = [ "/home/nmurray" ];

      exclude_if_present = [ ".nobackup" "CACHEDIR.TAG" ];

      exclude_patterns = [
        # NOT excluded on purpose: ~/.config/sops/age/keys.txt and ~/.ssh/borgbase_ed25519

        # Caches / regenerable
        "/home/nmurray/.cache"
        "/home/nmurray/.var/app/*/cache"
        "/home/nmurray/.recoll"
        "/home/nmurray/.venvs"
        "/home/nmurray/borg-browse"
        "/home/nmurray/borg_viewer"
        "sh:/home/nmurray/**/node_modules"

        # Vivaldi: keep bookmarks/prefs, drop caches
        "sh:/home/nmurray/.config/vivaldi/**/*Cache*"
        "sh:/home/nmurray/.config/vivaldi/**/WebStorage"
        "sh:/home/nmurray/.config/vivaldi/**/Service Worker"
        "sh:/home/nmurray/.config/vivaldi/**/IndexedDB"
        "sh:/home/nmurray/.config/vivaldi/**/Local Storage"
        "sh:/home/nmurray/.config/vivaldi/**/Session Storage"
        "sh:/home/nmurray/.config/vivaldi/**/GPUCache"
        "sh:/home/nmurray/.config/vivaldi/**/DawnGraphiteCache"
        "sh:/home/nmurray/.config/vivaldi/**/DawnWebGPUCache"
        "sh:/home/nmurray/.config/vivaldi/**/blob_storage"
        "sh:/home/nmurray/.config/vivaldi/**/Crashpad"
        "/home/nmurray/.config/vivaldi/Safe Browsing"
        "/home/nmurray/.config/vivaldi/component_crx_cache"
        "/home/nmurray/.config/vivaldi/extensions_crx_cache"

        # LibreWolf: disposable browser
        "/home/nmurray/.config/librewolf"

        # Regenerable app/system state
        "/home/nmurray/.local/share/containers"
        "/home/nmurray/.local/share/baloo"
        "/home/nmurray/.local/share/klipper"
        "/home/nmurray/.local/share/Trash"
        "/home/nmurray/.local/share/flatpak"

        # Flatpak apps not worth backing up (SimpleX, FluffyChat, Bitwarden are kept)
        "/home/nmurray/.var/app/org.chromium.Chromium"
        "/home/nmurray/.var/app/com.google.Chrome"
        "/home/nmurray/.var/app/us.zoom.Zoom"
        "/home/nmurray/.var/app/io.gitlab.librewolf-community"

        # AppImage extraction
        "/home/nmurray/virt/squashfs-root"
        "/home/nmurray/virt/Crashpad"
        "/home/nmurray/virt/bin"

        # Reinstall is done / photos live in Immich
        "/home/nmurray/Downloads"
      ];

      # Only touch borgmatic's own archives; Vorta-era archives are left alone
      match_archives = "sh:titan-borgmatic-*";

      keep_daily = 7;
      keep_weekly = 4;
      keep_monthly = 6;
      keep_yearly = 1;

      checks = [
        { name = "repository"; frequency = "2 weeks"; }
        { name = "archives"; frequency = "1 month"; }
      ];

      retries = 5;
      retry_wait = 5;
    };
  };

  # 3x/day, catch-up on wake
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
