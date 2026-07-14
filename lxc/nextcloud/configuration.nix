{ config, pkgs, lib, ... }:

{
  networking.hostName = "nextcloud";

  # override base's DHCP networking with a static IP
  # LXC 700 -> 10.10.40.70 (ID/10 = last octet scheme)
  systemd.network.networks."99-eth0" = lib.mkForce {
    matchConfig.Name = "eth0";
    networkConfig = {
      DHCP = "no";
      Address = [ "10.10.40.70/24" ];
      Gateway = "10.10.40.1";
    };
    linkConfig.RequiredForOnline = "routable";
  };

  sops.secrets.nextcloud-admin-pass = {
    sopsFile = ../../secrets/nextcloud/nextcloud.yaml;
    owner = "nextcloud";
  };
  sops.secrets.nextcloud-db-pass = {
    sopsFile = ../../secrets/nextcloud/nextcloud.yaml;
    owner = "nextcloud";
  };


  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud33;
    hostName = "cloud.doghouse.internal";

    # data directory lives on vdata (spinning rust) mount point,
    # separate from rootfs (SSD) — see Proxmox mp0 definition
    datadir = "/var/lib/nextcloud/data";

    config = {
      dbtype = "pgsql";
      adminuser = "admin";
      adminpassFile = config.sops.secrets.nextcloud-admin-pass.path;
      dbuser = "nextcloud";
      dbpassFile = config.sops.secrets.nextcloud-db-pass.path;
      dbhost = "127.0.0.1";
      dbname = "nextcloud";
    };

    settings = {
      trusted_domains = [ "cloud.doghouse.internal" "10.10.40.70" ];
      overwriteprotocol = "https";
    };

    maxUploadSize = "16G";
    https = false;
  };

  services.redis.servers.nextcloud = {
     enable = true;
     port = 0;
     unixSocket = "/run/redis-nextcloud/redis.sock";
     unixSocketPerm = 770;
   };

  services.nextcloud.configureRedis = true; 

    services.postgresql = {
    enable = true;
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [{
      name = "nextcloud";
      ensureDBOwnership = true;
    }];
  };

  systemd.services.postgresql-nextcloud-password = {
    description = "Sync nextcloud postgres role password from sops secret";
    after = [ "postgresql.service" "sops-nix.service" ];
    requires = [ "postgresql.service" ];
    wantedBy = [ "multi-user.target" ];
    before = [ "nextcloud-setup.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.sudo}/bin/sudo -u postgres ${config.services.postgresql.package}/bin/psql -c \
        "ALTER ROLE nextcloud WITH PASSWORD '$(cat ${config.sops.secrets.nextcloud-db-pass.path})';"
    '';
  };
}

