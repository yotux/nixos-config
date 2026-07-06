{ config, lib, pkgs, ... }:
with lib;
let cfg = config.myModules.mqtt;
in {
  options.myModules.mqtt = {
    enable = mkEnableOption "Mosquitto MQTT broker";
  };

  config = mkIf cfg.enable {
    sops.secrets.frigate_mqtt_password = {
      sopsFile = ../../secrets/mqtt/frigate.yaml;
    };

    services.mosquitto = {
      enable = true;
      listeners = [
        {
          port = 1883;
          users = {
            frigate = {
              passwordFile = config.sops.secrets.frigate_mqtt_password.path;
              acl = [ "readwrite frigate/#" ];
            };
          };
          settings.allow_anonymous = true;  # keep for HA/testing for now
        }
      ];
    };
    networking.firewall.allowedTCPPorts = [ 1883 ];
  };
}
