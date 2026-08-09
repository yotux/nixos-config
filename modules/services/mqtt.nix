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
    sops.secrets.homeassistant_mqtt_password = {
      sopsFile = ../../secrets/mqtt/homeassistant.yaml;
    };
    sops.secrets.iot_devices_mqtt_password = {
      sopsFile = ../../secrets/mqtt/iot-devices.yaml;
    };
    sops.secrets.nmurray_mqtt_password = {
      sopsFile = ../../secrets/mqtt/nmurray.yaml;
    };
    sops.secrets."shelly_mqtt_password" = {
      sopsFile = ../../secrets/mqtt/shelly.yaml;
    };

    services.mosquitto = {
      enable = true;
      listeners = [
        {
          port = 1883;
          users = {
            # Full admin - Home Assistant core instance
            homeassistant = {
              passwordFile = config.sops.secrets.homeassistant_mqtt_password.path;
              acl = [ "readwrite #" ];
            };

            # Frigate - its own namespace, plus read access to HA's status topic
            frigate = {
              passwordFile = config.sops.secrets.frigate_mqtt_password.path;
              acl = [
                "readwrite frigate/#"
                "read homeassistant/status"
              ];
            };

            # Shared account for low-risk IoT devices (smart plugs, sensors, lights)
            # NOTE: adjust topic prefix below to match your actual device naming
            iot_devices = {
              passwordFile = config.sops.secrets.iot_devices_mqtt_password.path;
              acl = [ "readwrite iot/#" ];
            };

	    # Shelly plug - own topic namespace under iot/
            shelly = {
              passwordFile = config.sops.secrets.shelly_mqtt_password.path;
              acl = [ "readwrite iot/shelly/#" ];
            };

            # Personal/admin account - full access, for manual debugging and
            # monitoring from titan (renamed from the earlier "titan" test user)
            nmurray = {
              passwordFile = config.sops.secrets.nmurray_mqtt_password.path;
              acl = [ "readwrite #" ];
            };
          };
          settings.allow_anonymous = false;  # keep for HA/testing for now
        }
      ];
    };
    networking.firewall.allowedTCPPorts = [ 1883 ];
  };
}
