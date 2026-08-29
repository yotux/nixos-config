{ pkgs, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor = ",preferred,auto,1"; # 1366x768 panel, auto-detect is fine here

      "$mod" = "SUPER";

      exec-once = [
        "waybar"
        "mako"
      ];

      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
      };

      input = {
        kb_layout = "us";
        follow_mouse = 1;
      };

      bind = [
        "$mod, Return, exec, kitty"                 # terminal - swap for your terminal of choice
        "$mod, Q, killactive"
        "$mod, R, exec, wofi --show drun"
        "$mod, F, fullscreen"
        "$mod SHIFT, Space, togglefloating"

        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"

        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"

        "$mod, PRINT, exec, grim -g \"$(slurp)\" - | wl-copy"
      ];
    };
  };

  home.packages = with pkgs; [
    kitty        # terminal
    wofi         # launcher
    mako         # notifications
    grim         # screenshot
    slurp        # region select for screenshot
    wl-clipboard # clipboard
  ];
}
