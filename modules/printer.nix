## printer.nix
{ config, pkgs, ... }:

{

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplipWithPlugin ];
  hardware.sane.extraBackends = [ pkgs.hplip ];

  services.avahi = {
  enable = true;
  nssmdns4 = true;
  openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    orca-slicer
  ];

}
