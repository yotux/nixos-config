{ config, pkgs, ... }:
{
  home.username = "nmurray";
  home.homeDirectory = "/home/nmurray";
  home.stateVersion = "26.11";

  home.packages = with pkgs; [
    sqlite
    kmymoney
  ];

  imports = [
    ./git.nix
#    ./hyprland.nix
#    ./waybar.nix
#    ./mako.nix
#    ./dock.nix
  ];
}
