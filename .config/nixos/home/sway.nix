{ lib, pkgs, ... }:
{
  programs.kitty = {
    enable = true;
  };
  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      # Use kitty as default terminal
      terminal = "kitty";
    };
  };
}
