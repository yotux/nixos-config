{ config, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
  # package name
  vorta
  vlc
  nmap
  recoll
  ];
}
