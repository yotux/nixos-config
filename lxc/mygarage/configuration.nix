{ config, ... }: {

  imports = [ 
    ../../modules/services/mygarage.nix
    ../../modules/services/mygarage-test.nix   # new
    ../../modules/services/tracktor.nix
    ../../modules/services/may.nix
  ];

  systemd.network.networks."50-eth0" = {
    matchConfig.Name = "eth0";
    networkConfig = {
      Address = "10.10.40.60/24";
      Gateway = "10.10.40.1";
      DNS = "10.10.40.1";
    };
    linkConfig.RequiredForOnline = "routable";
  };

  myModules.mygarage.enable = true;
  myModules.mygarageTest.enable = true;        # new
  myModules.tracktor.enable = true;
  myModules.may.enable = true;
}

