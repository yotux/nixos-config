{ pkgs, ... }:

{
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 32;

        modules-left = [
          "hyprland/workspaces"
        ];

        modules-center = [
          "hyprland/window"
        ];

        modules-right = [
          "tray"
          "network"
          "pulseaudio"
          "clock"
        ];

        "hyprland/workspaces" = {
          format = "{name}";
          on-click = "activate";
        };

        "hyprland/window" = {
          format = "{}";
          max-length = 50;
        };

        "tray" = {
          spacing = 8;
        };

        "network" = {
          format-wifi = "  {essid}";
          format-ethernet = "󰈀  {ipaddr}";
          format-disconnected = "󰤭  Disconnected";
          tooltip-format = "{ifname}: {ipaddr}";
        };

        "pulseaudio" = {
          format = "{icon}  {volume}%";
          format-muted = "󰝟  Muted";

          format-icons = [
            ""
            ""
            ""
          ];

          on-click = "pavucontrol";
        };

        "clock" = {
          format = "{:%a %b %d  %I:%M %p}";
          tooltip-format = "<big>{:%B %Y}</big>\n<tt>{calendar}</tt>";
        };
      };
    };

    style = ''
      * {
        font-family: "sans-serif", "JetBrainsMono Nerd Font";
        font-size: 13px;
      }

      window#waybar {
        background: rgba(25, 25, 25, 0.90);
        color: #ffffff;
      }

      #workspaces button {
        padding: 0 8px;
        color: #aaaaaa;
        background: transparent;
        border: none;
      }

      #workspaces button.active {
        color: #ffffff;
        background: rgba(255, 255, 255, 0.12);
      }

      #tray,
      #network,
      #pulseaudio,
      #clock {
        padding: 0 12px;
      }
    '';
  };

  home.packages = with pkgs; [
    pavucontrol
    nerd-fonts.jetbrains-mono
  ];
}

