#obs.nix
{ config, pkgs, ... }:
{
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      # capture / pipeline
      wlrobs
      obs-pipewire-audio-capture
      obs-vkcapture
      obs-gstreamer
      obs-vaapi
      obs-source-record
      obs-multi-rtmp
      obs-teleport
      droidcam-obs
#      distroav  #obs-ndi

      # scenes / transitions / automation
      advanced-scene-switcher
      # obs-move-transition debug
      obs-scene-as-transition
      obs-transition-table
      # obs-source-switcher  # fails to build against OBS 32.2.2 (-Werror on deprecated API)
      obs-source-clone
      # obs-replay-source debug
      obs-command-source

      # filters / visuals
      obs-backgroundremoval
      # obs-shaderfilter debug
      obs-composite-blur
      # obs-stroke-glow-shadow
      obs-rgb-levels  #obs-rgb-levels-filter
      obs-freeze-filter
      obs-vintage-filter
      obs-3d-effect
      obs-gradient-source

      # overlays / misc
      input-overlay
      obs-tuna
      obs-media-controls
      obs-markdown
      obs-mute-filter
      waveform
      #system plugh
      obs-color-monitor     # waveform/vectorscope for judging capture color
      obs-wayland-hotkeys   # global hotkeys on Wayland
    ];
  };
}
