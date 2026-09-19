{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nwg-dock-hyprland
  ];

  home.file.".config/nwg-dock-hyprland/style.css".text = ''
    window {
      background: rgba(25, 25, 25, 0.90);
      border-radius: 12px;
    }

    button {
      background: transparent;
      border: none;
      padding: 4px;
      margin: 2px;
      border-radius: 8px;
    }

    button:hover {
      background: rgba(255, 255, 255, 0.12);
    }
  '';
}
