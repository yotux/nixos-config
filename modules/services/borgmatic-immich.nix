{ config, pkgs, ... }: {

  sops.secrets.borg_immich_passphrase = {
    sopsFile = ../../secrets/immich/borg-passphrase.yaml;
    owner = "root";
  };

  services.borgmatic = {
    enable = true;

    settings = {
      archive_name_format = "immich-borgmatic-{now:%Y-%m-%dT%H:%M:%S}";
      repositories = [
        {
          path = "ssh://zwns27m7@zwns27m7.repo.borgbase.com/./repo";
          label = "borgbase-immich";
        }
      ];

      ssh_command = "ssh -i /root/.ssh/borgbase_immich_ed25519 -o IdentitiesOnly=yes";

      # /var/lib/immich already contains upload/, library/, profile/,
      # thumbs/, encoded-video/, and backups/ (Immich's own automatic
      # gzipped pg_dump, created daily ~2am per its own retention setting).
      # No separate pg_dump needed here - relying on Immich's built-in
      # DB backup job, per official guidance on backup ordering.
      source_directories = [
        "/var/lib/immich"
      ];

      encryption_passcommand = "cat /run/secrets/borg_immich_passphrase";

      keep_daily = 7;
      keep_weekly = 4;
      keep_monthly = 6;
      keep_yearly = 1;

      retries = 5;
      retry_wait = 5;
    };
  };

  # Runs 2 hours after Immich's own default DB backup job (2am),
  # so Borg always captures a fresh, complete dump alongside the files.
  systemd.timers.borgmatic.timerConfig = {
    OnCalendar = "*-*-* 04:00:00";
    Persistent = true;
    RandomizedDelaySec = "15m";
  };

  systemd.services.borgmatic.serviceConfig = {
    User = "root";
  };
}
