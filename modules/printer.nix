{ config, pkgs, ... }:

{

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplipWithPlugin ];

  services.avahi = {
  enable = true;
  nssmdns4 = true;
  openFirewall = true;
  };

}
