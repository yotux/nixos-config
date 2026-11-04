{ config, lib, pkgs, ... }:
with lib;
let cfg = config.myModules.mygarageRc;
in {
  options.myModules.mygarageRc = {
    enable = mkEnableOption "upstream MyGarage release-candidate instance on :8688";
    image = mkOption {
      type = types.str;   # no default: forces you to pin an exact tag
      description = "Pinned upstream image, e.g. ghcr.io/homelabforge/mygarage:<tag>";
    };
    autoStartApp = mkOption {
      type = types.bool;
      default = false;    # keep false until the dump is loaded
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    sops.secrets."mygarage_rc_env" = {
      sopsFile = ../../secrets/mygarage/env.yaml;
      key = "mygarage_env";
      owner = "root";
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/mygarage-rc 0755 root root -"
      "d /var/lib/mygarage-rc/data 0777 root root -"
    ];

    systemd.services.docker-network-mygarage-rc = {
      description = "Create mygarage-rc docker network";
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = { Type = "oneshot"; RemainAfterExit = true; };
      script = ''
        ${pkgs.docker}/bin/docker network inspect mygarage-rc-net >/dev/null 2>&1 || \
        ${pkgs.docker}/bin/docker network create mygarage-rc-net
      '';
    };

    virtualisation.oci-containers.containers = {
      mygarage-rc-postgres = {
        image = "postgres:16-alpine";
        environment = { POSTGRES_DB = "mygarage"; POSTGRES_USER = "mygarage"; };
        environmentFiles = [ config.sops.secrets."mygarage_rc_env".path ];
        volumes = [ "/var/lib/mygarage-rc/postgres:/var/lib/postgresql/data" ];
        extraOptions = [ "--network=mygarage-rc-net" "--network-alias=postgres" ];
      };
      mygarage-rc = {
        image = cfg.image;
        autoStart = cfg.autoStartApp;
        dependsOn = [ "mygarage-rc-postgres" ];
        ports = [ "8688:8686" ];
        volumes = [ "/var/lib/mygarage-rc/data:/data" ];
        environmentFiles = [ config.sops.secrets."mygarage_rc_env".path ];
        extraOptions = [ "--network=mygarage-rc-net" ];
      };
    };

    systemd.services.docker-mygarage-rc-postgres = {
      after = [ "docker-network-mygarage-rc.service" ];
      requires = [ "docker-network-mygarage-rc.service" ];
    };
    systemd.services.docker-mygarage-rc = {
      after = [ "docker-network-mygarage-rc.service" ];
      requires = [ "docker-network-mygarage-rc.service" ];
    };

    networking.firewall.allowedTCPPorts = [ 8688 ];
  };
}
