# home/alarsan68.nix
# Requires home-manager flake
{ pkgs, ... }: {

  home.username = "alarsan68";
  home.homeDirectory = "/home/alarsan68";

  home.packages = with pkgs; [
    openssh
  ];

  programs.git.userEmail = "albertlarsan@albertlarsan.fr";
  programs.gpg.mutableKeys = true;
  programs.gpg.mutableTrust = true;

  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
      ];
      favorite-apps = [
        "zen.desktop"
        "org.keepassxc.KeePassXC.desktop"
        "org.gnome.Console.desktop"
      ];
    };
  };

  home.stateVersion = "24.11";
}

