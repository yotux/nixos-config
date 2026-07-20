## software.nix
{ config, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    vlc
    nmap
    recoll
    neovim
    ghostty
    wget
    tealdeer
    xclip
    bat
    gparted
    writedisk
    mqttx
    bind
    # passmark-performancetest
    appimage-run
    naps2
    borgmatic
  ];
}
