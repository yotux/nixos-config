{ pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      monitor = ",preferred,auto,1";

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
        "SUPER, Return, exec, kitty"
        "SUPER, Q, killactive"
        "SUPER, R, exec, wofi --show drun"
        "SUPER, F, fullscreen"
        "SUPER SHIFT, Space, togglefloating"

        "SUPER, H, movefocus, l"
        "SUPER, L, movefocus, r"
        "SUPER, K, movefocus, u"
        "SUPER, J, movefocus, d"

        "SUPER, 1, workspace, 1"
        "SUPER, 2, workspace, 2"
        "SUPER, 3, workspace, 3"
        "SUPER, 4, workspace, 4"

        "SUPER SHIFT, 1, movetoworkspace, 1"
        "SUPER SHIFT, 2, movetoworkspace, 2"
        "SUPER SHIFT, 3, movetoworkspace, 3"
        "SUPER SHIFT, 4, movetoworkspace, 4"
	"SUPER, PRINT, exec, /home/nmurray/bin/hypr-screenshot"
      ];
    };
  };

  home.packages = with pkgs; [
    kitty
    wofi
    mako
    grim
    slurp
    wl-clipboard
  ];
}
