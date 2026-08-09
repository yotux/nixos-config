{ config, lib, pkgs, ... }:
with lib;
let cfg = config.myModules.telegraf;
in {
  options.myModules.telegraf = {
    enable = mkEnableOption "Telegraf MQTT-to-InfluxDB bridge";
  };

  config = mkIf cfg.enable {
    sops.secrets.shelly_mqtt_password = {
      sopsFile = ../../secrets/mqtt/shelly-telegraf.yaml;
    };

    sops.secrets.telegraf_influx_token = {
      sopsFile = ../../secrets/influxdb/iotawatt-token.yaml;
      key = "iotawatt_token";
    };

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
          
          # FIX 1: Listen to the actual Gen 1 Shelly topics
          topics = [ 
            "shellies/shellyem-B0E4CA/emeter/+/power"
            "shellies/shellyem-B0E4CA/emeter/+/voltage"
            "shellies/shellyem-B0E4CA/emeter/+/total"
          ]; 
          
          # FIX 2: Use the username that matches your Mosquitto ACL block
          username = "shelly"; 
          password = "$SHELLY_MQTT_PASSWORD";
          
          # FIX 3: Parse raw numerical text strings instead of expecting JSON arrays
          data_format = "value";
          data_type = "float";
          name_override = "shelly_solar";

          # BONUS FIX: This parses the topic into searchable fields inside InfluxDB
          topic_parsing = [{
            topic = "shellies/+/emeter/+/+";
            measurement = "measurement/_/_/_/_";
            tags = "_/device_id/_/channel/_";
          }];
        }];

        outputs.influxdb_v2 = [{
          urls = [ "http://10.10.40.40:8086" ];
          token = "$INFLUX_API_TOKEN";
          organization = "proxmox"; # Ensure this matches your actual InfluxDB org name
          bucket = "iotawatt";
        }];
      };
    };
  };
}
