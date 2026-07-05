{ config, lib, pkgs, ... }:
with lib;
let cfg = config.myModules.mqtt;
in {
  options.myModules.mqtt = {
    enable = mkEnableOption "Mosquitto MQTT broker";
  };

  config = mkIf cfg.enable {
    services.mosquitto = {
      enable = true;
      listeners = [
        {
          port = 1883;
          users = {
            # Add users via sops-nix later
          };
        }
      ];
    };
    networking.firewall.allowedTCPPorts = [ 1883 ];
  };
}
