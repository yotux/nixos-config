{ config, pkgs, ... }: {

  systemd.network.networks."50-eth0" = {
    matchConfig.Name = "eth0";
    networkConfig = {
      Address = "10.10.40.21/24";
      Gateway = "10.10.40.1";
      DNS = "10.10.40.1";
    };
    linkConfig.RequiredForOnline = "routable";
  };

  sops.secrets.samba_password = {
    sopsFile = ../../secrets/ha-backup/samba-password.yaml;
    owner = "root";
  };

  systemd.tmpfiles.rules = [
    "d /srv/ha-backups 0770 hasmb hasmb -"
  ];

  users.groups.hasmb = {};
  users.users.hasmb = {
    isSystemUser = true;
    group = "hasmb";
    createHome = false;
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "ha-backup";
        "security" = "user";
        "map to guest" = "never";
      };
      "ha-backups" = {
        "path" = "/srv/ha-backups";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "hasmb";
        "force user" = "hasmb";
        "force group" = "hasmb";
        "create mask" = "0660";
        "directory mask" = "0770";
      };
    };
  };

  systemd.services.set-samba-password = {
    description = "Set hasmb samba password from sops secret";
    after = [ "samba-smbd.service" "sops-nix.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      PASS=$(cat ${config.sops.secrets.samba_password.path})
      (echo "$PASS"; echo "$PASS") | ${pkgs.samba}/bin/smbpasswd -a -s hasmb
    '';
  };
}
