{ config, lib, ... }:
with lib;
let cfg = config.myModules.tracktor;
in {
  options.myModules.tracktor.enable = mkEnableOption "tracktor vehicle tracker (docker)";

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    virtualisation.oci-containers.containers.tracktor = {
      image = "ghcr.io/javedh-dev/tracktor:2.1.0"; # verify tag exists on ghcr
      ports = [ "3333:3000" ];
      volumes = [ "/var/lib/tracktor:/data" ];
      environment = {
        TRACKTOR_DEMO_MODE = "false";
        FORCE_DATA_SEED = "false";
        CORS_ORIGINS = "http://10.10.40.60:3333"; # change to proxy URL if fronted
      };
    };

    systemd.tmpfiles.rules = [ "d /var/lib/tracktor 0755 root root -" ];
    networking.firewall.allowedTCPPorts = [ 3333 ];
  };
}
