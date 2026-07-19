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

      source_directories = [
        "/var/lib/immich"
        "/var/backups/immich-postgres"
      ];

      encryption_passcommand = "cat /run/secrets/borg_immich_passphrase";

      before_backup = [
        "mkdir -p /var/backups/immich-postgres"
        "sudo -u postgres pg_dump immich > /var/backups/immich-postgres/immich-$(date +%Y%m%d-%H%M%S).sql"
        "find /var/backups/immich-postgres -type f -mtime +3 -delete"
      ];

      keep_daily = 7;
      keep_weekly = 4;
      keep_monthly = 6;
      keep_yearly = 1;

      retries = 5;
      retry_wait = 5;
    };
  };

  systemd.timers.borgmatic.timerConfig = {
    OnCalendar = "*-*-* 04:00:00";
    Persistent = true;
    RandomizedDelaySec = "15m";
  };

  systemd.services.borgmatic.serviceConfig = {
    User = "root";
  };
}
