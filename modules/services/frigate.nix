{ config, lib, pkgs, ... }:
with lib;
let cfg = config.myModules.frigate;
in {
  options.myModules.frigate = {
    enable = mkEnableOption "Frigate NVR (docker)";
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;

    sops.secrets.frigate-plus-api-key = {
      sopsFile = ../../secrets/frigate/env.yaml;
      owner = "root";
    };

    virtualisation.oci-containers.containers.frigate = {
      image = "ghcr.io/blakeblackshear/frigate:stable";
      environmentFiles = [ config.sops.secrets.frigate-plus-api-key.path ];
      volumes = [
        "/home/nmurray/frigate/config:/config"
        "/mnt/data:/media/frigate"
      ];
      ports = [
        "8971:8971"
        "8554:8554"
        "5000:5000"
      ];
      extraOptions = [
        "--device=/dev/dri/renderD128:/dev/dri/renderD128"
        "--shm-size=512mb"
        "--tmpfs=/tmp/cache:size=1000000000"
      ];
    };

    networking.firewall.allowedTCPPorts = [ 5000 8554 8971 ];
  };
}
