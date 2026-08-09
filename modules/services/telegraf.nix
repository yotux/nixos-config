{ config, lib, pkgs, ... }:
with lib;
let cfg = config.myModules.telegraf;
in {
  options.myModules.telegraf = {
    enable = mkEnableOption "Telegraf MQTT-to-InfluxDB bridge";
  };

  config = mkIf cfg.enable {
    # New secret: the Shelly's dedicated MQTT broker password.
    # Create secrets/mqtt/shelly-telegraf.yaml (sops) with key: shelly_mqtt_password
    sops.secrets.shelly_mqtt_password = {
      sopsFile = ../../secrets/mqtt/shelly-telegraf.yaml;
    };

    # Reuses the existing iotawatt-token.yaml secret you already have —
    # check it has write access to the bucket before relying on it;
    # if not, mint a separate token and point this at a new secret file instead.
    sops.secrets.telegraf_influx_token = {
      sopsFile = ../../secrets/influxdb/iotawatt-token.yaml;
      key = "iotawatt_token";
    };

    # sops-nix templating builds a real KEY=VALUE env file at runtime from
    # the two secrets above, without ever writing the plaintext into the
    # nix store or your repo.
    sops.templates."telegraf.env".content = ''
      SHELLY_MQTT_PASSWORD=${config.sops.placeholder.shelly_mqtt_password}
      INFLUX_API_TOKEN=${config.sops.placeholder.telegraf_influx_token}
    '';

    services.telegraf = {
      enable = true;
      environmentFiles = [ config.sops.templates."telegraf.env".path ];

      extraConfig = {
        inputs.mqtt_consumer = [{
          servers = [ "tcp://10.10.40.50:1883" ];
          topics = [ "shellyem-garage-solar/#" ]; # narrow allowlist — Frigate's topics never touch this
          username = "shelly-garage-em";
          password = "$SHELLY_MQTT_PASSWORD";
          data_format = "json";
          name_override = "shelly_solar";
        }];

        outputs.influxdb_v2 = [{
          urls = [ "http://10.10.40.40:8086" ];
          token = "$INFLUX_API_TOKEN";
          organization = "your-org"; # match your actual InfluxDB org name
          bucket = "iotawatt";
        }];
      };
    };
  };
}

