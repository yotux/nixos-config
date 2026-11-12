{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myModules.dnclient;

  dnclient = pkgs.stdenv.mkDerivation {
    pname = "dnclient";
    version = "1.0.0";

    src = pkgs.fetchurl {
      url = "https://dl.defined.net/837870e1/v1.0.0/linux/amd64/dnclient";
      hash = "sha256-XXri9G5PM2k+yq/MVMj78t7KVCCSNOTwaVjacQHGPoY=";
    };

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/dnclient
      chmod +x $out/bin/dnclient
    '';
  };
in {
  options.myModules.dnclient = {
    enable = mkEnableOption "Defined Networking dnclient (Nebula mesh)";
  };

  config = mkIf cfg.enable {
    systemd.services.dnclient = {
      description = "Defined Networking dnclient (Nebula mesh)";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${dnclient}/bin/dnclient run";
        Restart = "always";
        RestartSec = "5s";
        StateDirectory = "defined";
      };
    };

    environment.systemPackages = [ dnclient ];
  };
}
