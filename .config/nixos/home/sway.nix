{ lib, pkgs, ... }:
{
  # home.pointerCursor.sway.enable = true;
  programs.kitty = {
    enable = true;
  };
  programs.swaylock.enable = true;
  programs.waybar.enable = true;
  wayland.windowManager.sway = {
    enable = true;
    checkConfig = true;
    config = rec {
      defaultWorkspace = "workspace number 1";
      modifier = "Mod4";
      # Use kitty as default terminal
      terminal = "${pkgs.kitty}/bin/kitty";
      bars = [
        {command = "${pkgs.waybar}/bin/waybar";}
      ];
    };
    systemd.xdgAutostart = true;
    wrapperFeatures.gtk = true;
  };
}
