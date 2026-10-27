{ config, lib, ... }:
with lib;
let cfg = config.myModules.may;
in {
  options.myModules.may.enable = mkEnableOption "may vehicle tracker (docker)";

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    sops.secrets."may_env" = {
      sopsFile = ../../secrets/may/env.yaml;
      owner = "root";
    };

    virtualisation.oci-containers.containers.may = {
      image = "ghcr.io/dannymcc/may:latest"; # pin once you've checked tags
      ports = [ "5050:5050" ];
      volumes = [ "/var/lib/may:/app/data" ];
      environment = {
        PUID = "1000";
        PGID = "1000";
      };
      environmentFiles = [ config.sops.secrets."may_env".path ];
    };

    systemd.tmpfiles.rules = [ "d /var/lib/may 0755 1000 1000 -" ];
    networking.firewall.allowedTCPPorts = [ 5050 ];
  };
}
