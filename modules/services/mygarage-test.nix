{ config, lib, pkgs, ... }:
with lib;
let cfg = config.myModules.mygarageTest;
in {
  options.myModules.mygarageTest = {
    enable = mkEnableOption "patched per-mile test instance of mygarage on :8687";
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    # Same env file as the main instance, declared under its own name so this
    # module works whether or not myModules.mygarage is enabled.
    sops.secrets."mygarage_test_env" = {
      sopsFile = ../../secrets/mygarage/env.yaml;
      key = "mygarage_env";
      owner = "root";
    };

    systemd.services.docker-network-mygarage-test = {
      description = "Create mygarage-test docker network";
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = { Type = "oneshot"; RemainAfterExit = true; };
      script = ''
        ${pkgs.docker}/bin/docker network inspect mygarage-test-net >/dev/null 2>&1 || \
        ${pkgs.docker}/bin/docker network create mygarage-test-net
      '';
    };

    virtualisation.oci-containers.containers = {
      mygarage-test-postgres = {
        image = "postgres:16-alpine";
        environment = {
          POSTGRES_DB = "mygarage";
          POSTGRES_USER = "mygarage";
        };
        environmentFiles = [ config.sops.secrets."mygarage_test_env".path ];
        volumes = [ "/var/lib/mygarage-test/postgres:/var/lib/postgresql/data" ];
        extraOptions = [
          "--network=mygarage-test-net"
          "--network-alias=postgres"
        ];
      };

      mygarage-test = {
        image = "mygarage-permile:latest";
        dependsOn = [ "mygarage-test-postgres" ];
        ports = [ "8687:8686" ];
        volumes = [ "/var/lib/mygarage-test/data:/data" ];
        environmentFiles = [ config.sops.secrets."mygarage_test_env".path ];
        extraOptions = [ "--network=mygarage-test-net" ];
      };
    };

    systemd.services.docker-mygarage-test-postgres = {
      after = [ "docker-network-mygarage-test.service" ];
      requires = [ "docker-network-mygarage-test.service" ];
    };
    systemd.services.docker-mygarage-test = {
      after = [ "docker-network-mygarage-test.service" ];
      requires = [ "docker-network-mygarage-test.service" ];
    };

    networking.firewall.allowedTCPPorts = [ 8687 ];
  };
}
