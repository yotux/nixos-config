{ config, lib, pkgs, ... }:
with lib;
let cfg = config.myModules.immich;
in {
  options.myModules.immich = {
    enable = mkEnableOption "Immich photo management";
  };

  config = mkIf cfg.enable {
    services.immich = {
      enable = true;
      host = "0.0.0.0";
      port = 2283;
      mediaLocation = "/var/lib/immich";
      accelerationDevices = [ "/dev/dri/renderD128" ];
    };

    hardware.graphics = {
      enable = true;
    };

    networking.firewall.allowedTCPPorts = [ 2283 ];
  };
}
