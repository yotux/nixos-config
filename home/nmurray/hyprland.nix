{ pkgs, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      -- Basic layout appearance
      hl.config({
        general = {
          gaps_in = 4,
          gaps_out = 8,
          border_size = 2,
        },
        input = {
          kb_layout = "us",
          follow_mouse = 1,
        },
      })
      -- Monitor setup
      hl.monitor({
        output = "",
        mode = "preferred",
        position = "auto",
        scale = 1,
      })

      -- Autostart
      hl.on("hyprland.start", function()
        hl.exec_cmd("waybar")
        hl.exec_cmd("nm-applet --indicator")
        hl.exec_cmd("lxpolkit")
        hl.exec_cmd("nwg-dock-hyprland -d")
      end)

      -- Core desktop shortcuts
      hl.bind("SUPER+Return", hl.dsp.exec_cmd("kitty"))
      hl.bind("SUPER+Q", hl.dsp.window.close())
      hl.bind("SUPER+B", hl.dsp.exec_cmd("flatpak run org.chromium.Chromium"))
      hl.bind("Print", hl.dsp.exec_cmd("/home/nmurray/bin/hypr-screenshot"))

      -- App launchers & menus
      hl.bind("SUPER+D", hl.dsp.exec_cmd("rofi -show drun"))
      hl.bind("SUPER+E", hl.dsp.exec_cmd("thunar"))
      hl.bind("SUPER+Escape", hl.dsp.exec_cmd("wlogout"))

      -- Move window focus
      hl.bind("SUPER+left", hl.dsp.focus({ direction = "left" }))
      hl.bind("SUPER+right", hl.dsp.focus({ direction = "right" }))
      hl.bind("SUPER+up", hl.dsp.focus({ direction = "up" }))
      hl.bind("SUPER+down", hl.dsp.focus({ direction = "down" }))

      -- Toggle floating
      hl.bind("SUPER+V", hl.dsp.window.float({ action = "toggle" }))

      -- Toggle dock manually (bypasses hotspot detection)
      hl.bind("SUPER+SHIFT+D", hl.dsp.exec_cmd("nwg-dock-hyprland -r"))

      -- Drag windows with SUPER + LMB, resize with SUPER + RMB
      hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
      hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

      -- Resize active window (repeat while held)
      hl.bind("SUPER+minus", hl.dsp.window.resize({ x = -20, y = 0 }), { repeating = true })
      hl.bind("SUPER+equal", hl.dsp.window.resize({ x = 20, y = 0 }), { repeating = true })
      hl.bind("SUPER+SHIFT+minus", hl.dsp.window.resize({ x = 0, y = -20 }), { repeating = true })
      hl.bind("SUPER+SHIFT+equal", hl.dsp.window.resize({ x = 0, y = 20 }), { repeating = true })

      -- Move windows to workspaces
      hl.bind("SUPER+SHIFT+1", hl.dsp.window.move({ workspace = "1", follow = true }))
      hl.bind("SUPER+SHIFT+2", hl.dsp.window.move({ workspace = "2", follow = true }))
      hl.bind("SUPER+SHIFT+3", hl.dsp.window.move({ workspace = "3", follow = true }))
      hl.bind("SUPER+SHIFT+4", hl.dsp.window.move({ workspace = "4", follow = true }))
      hl.bind("SUPER+SHIFT+5", hl.dsp.window.move({ workspace = "5", follow = true }))

      -- Workspace navigation
      hl.bind("SUPER+1", hl.dsp.focus({ workspace = "1" }))
      hl.bind("SUPER+2", hl.dsp.focus({ workspace = "2" }))
      hl.bind("SUPER+3", hl.dsp.focus({ workspace = "3" }))
      hl.bind("SUPER+4", hl.dsp.focus({ workspace = "4" }))
      hl.bind("SUPER+5", hl.dsp.focus({ workspace = "5" }))
    '';
  };

  home.packages = with pkgs; [
    kitty
    waybar
    grim
    slurp
    wl-clipboard
    rofi
    thunar
    wlogout
    pavucontrol
    networkmanagerapplet
    lxsession
  ];
}
