{ config, pkgs, ... }: {
  imports = [ ../../modules/services/caddy.nix ];
  systemd.network.networks."50-eth0" = {
    matchConfig.Name = "eth0";
    networkConfig = {
      Address = "10.10.40.10/24";
      Gateway = "10.10.40.1";
      DNS = "10.10.40.1";
    };
    linkConfig.RequiredForOnline = "routable";
  };
  sops.secrets.cloudflare-token = {
    sopsFile = ../../secrets/caddy/cloudflare.yaml;
    owner = "caddy";
  };
  myModules.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
      hash = "sha256-EXZTsf9KrIAi9gHsBHrYQ7oIQiYmLj6sYuQP5QihPcA=";
    };
    virtualHosts = {
      "10.10.40.10:80".extraConfig = ''
        respond "Caddy is working on hive"
      '';
      "mygarage.naterslab.com".extraConfig = ''
        reverse_proxy 10.10.40.60:8686
        tls {
          dns cloudflare {file.${config.sops.secrets.cloudflare-token.path}}
          resolvers 1.1.1.1
        }
      '';
      "cloud.naterslab.com".extraConfig = ''
        reverse_proxy 10.10.40.70:80
        tls {
          dns cloudflare {file.${config.sops.secrets.cloudflare-token.path}}
          resolvers 1.1.1.1
        }
      '';
    };
  };
}
