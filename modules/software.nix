## software.nix
{ config, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
  # package name
  vlc
  nmap
  recoll
  neovim
  ghostty
  sops
  age
  wget
  tealdeer
  xclip
  bat
  gh
  git-crypt
  gnupg
  pinentry-qt   # Use pinentry-qt on KDE for native GTK/Qt passphrase dialogs
  gparted
  writedisk
  vivaldi
  mqttx
  bind
  jq
  passmark-performancetest
  appimage-run
  ### iphone ttols
  libimobiledevice
  usbmuxd
  ifuse
  libplist
#  actual-server
  ];
  
  services.usbmuxd.enable = true;

}
