{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true; # needed for non-Wayland-native apps
  };

  # Portal support: screen share, file pickers from sandboxed/flatpak apps
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    config.common.default = "*";
  };

  # Needed so systemd user services (waybar, etc.) get the right env vars
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # hints Electron/Chromium apps to use native Wayland
  };
}
