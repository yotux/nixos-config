{ config, lib, pkgs, ... }:
with lib;
let cfg = config.myModules.frigate;
in {
  options.myModules.frigate = {
    enable = mkEnableOption "Frigate NVR (docker)";
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    sops.secrets = {
      frigate-plus-api-key = {
        sopsFile = ../../secrets/frigate/env.yaml;
        owner = "root";
      };
      "frigate/FRIGATE_MQTT_PASSWORD" = {
        sopsFile = ../../secrets/frigate/camera-passwords.yaml;
        key = "mqtt-password";
        owner = "root";
      };
      "frigate/FRIGATE_LIVING_ROOM_PASSWORD" = {
        sopsFile = ../../secrets/frigate/camera-passwords.yaml;
        key = "living-room-password";
        owner = "root";
      };
      "frigate/FRIGATE_KITCHEN_PASSWORD" = {
        sopsFile = ../../secrets/frigate/camera-passwords.yaml;
        key = "kitchen-password";
        owner = "root";
      };
      "frigate/FRIGATE_FRONT_DOOR_PASSWORD" = {
        sopsFile = ../../secrets/frigate/camera-passwords.yaml;
        key = "front-door-password";
        owner = "root";
      };
      "frigate/FRIGATE_DRIVEWAY_PASSWORD" = {
        sopsFile = ../../secrets/frigate/camera-passwords.yaml;
        key = "driveway-password";
        owner = "root";
      };
      "frigate/FRIGATE_GARAGE_INSIDE_PASSWORD" = {
        sopsFile = ../../secrets/frigate/camera-passwords.yaml;
        key = "garage-inside-password";
        owner = "root";
      };
      "frigate/FRIGATE_GARAGE_ONVIF_PASSWORD" = {
        sopsFile = ../../secrets/frigate/camera-passwords.yaml;
        key = "garage-onvif-password";
        owner = "root";
      };
    };

    virtualisation.oci-containers.containers.frigate = {
      image = "ghcr.io/blakeblackshear/frigate:stable";
      environmentFiles = [ config.sops.secrets.frigate-plus-api-key.path ];
      volumes = [
        "/home/nmurray/frigate/config:/config"
        "/mnt/frigate-storage:/media/frigate"
        "${config.sops.secrets."frigate/FRIGATE_MQTT_PASSWORD".path}:/run/secrets/FRIGATE_MQTT_PASSWORD:ro"
        "${config.sops.secrets."frigate/FRIGATE_LIVING_ROOM_PASSWORD".path}:/run/secrets/FRIGATE_LIVING_ROOM_PASSWORD:ro"
        "${config.sops.secrets."frigate/FRIGATE_KITCHEN_PASSWORD".path}:/run/secrets/FRIGATE_KITCHEN_PASSWORD:ro"
        "${config.sops.secrets."frigate/FRIGATE_FRONT_DOOR_PASSWORD".path}:/run/secrets/FRIGATE_FRONT_DOOR_PASSWORD:ro"
        "${config.sops.secrets."frigate/FRIGATE_DRIVEWAY_PASSWORD".path}:/run/secrets/FRIGATE_DRIVEWAY_PASSWORD:ro"
        "${config.sops.secrets."frigate/FRIGATE_GARAGE_INSIDE_PASSWORD".path}:/run/secrets/FRIGATE_GARAGE_INSIDE_PASSWORD:ro"
        "${config.sops.secrets."frigate/FRIGATE_GARAGE_ONVIF_PASSWORD".path}:/run/secrets/FRIGATE_GARAGE_ONVIF_PASSWORD:ro"
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
