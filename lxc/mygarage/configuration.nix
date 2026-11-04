{ config, ... }: {

  imports = [ 
    ../../modules/services/mygarage.nix
    # ../../modules/services/mygarage-test.nix   # new
    ../../modules/services/mygarage-rc.nix
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
  
  users.users.nmurray.extraGroups = [ "docker" ];

  myModules.mygarage.enable = true;
  # myModules.mygarageTest.enable = true;        # new
  myModules.mygarageRc = {
    enable = true;
    image = "ghcr.io/homelabforge/mygarage:3.10.0-rc2";
    autoStartApp = true;
  };
}

