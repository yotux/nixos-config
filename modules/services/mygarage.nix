{ config, lib, pkgs, ... }:
with lib;
let cfg = config.myModules.mygarage;
in {
  options.myModules.mygarage = {
    enable = mkEnableOption "mygarage vehicle tracker (docker, bundled postgres)";
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    sops.secrets."mygarage_env" = {
      sopsFile = ../../secrets/mygarage/env.yaml;
      owner = "root";
    };

    # Shared docker network so 'postgres' hostname resolves between containers
    systemd.services.docker-network-mygarage = {
      description = "Create mygarage docker network";
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        ${pkgs.docker}/bin/docker network inspect mygarage-net >/dev/null 2>&1 || \
        ${pkgs.docker}/bin/docker network create mygarage-net
      '';
    };

    virtualisation.oci-containers.containers = {
      mygarage-postgres = {
        image = "postgres:16-alpine";
        environment = {
          POSTGRES_DB = "mygarage";
          POSTGRES_USER = "mygarage";
        };
        environmentFiles = [ config.sops.secrets."mygarage_env".path ];
        volumes = [ "/var/lib/mygarage/postgres:/var/lib/postgresql/data" ];
        extraOptions = [
          "--network=mygarage-net"
          "--network-alias=postgres"
        ];
      };

      mygarage = {
        image = "ghcr.io/homelabforge/mygarage:latest";
        dependsOn = [ "mygarage-postgres" ];
        ports = [ "8686:8686" ];
        volumes = [ "/var/lib/mygarage/data:/data" ];
        environmentFiles = [ config.sops.secrets."mygarage_env".path ];
        extraOptions = [ "--network=mygarage-net" ];
      };
    };

    networking.firewall.allowedTCPPorts = [ 8686 ];
  };
}
