{ config, pkgs, ... }:
{
  home.username = "nmurray";
  home.homeDirectory = "/home/nmurray";
  home.stateVersion = "26.11";

  imports = [
    ./git.nix
    ./hyprland.nix
  ];
}
