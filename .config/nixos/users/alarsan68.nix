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
        "gsconnect@andyholmes.github.io"
        "nightthemeswitcher@romainvigier.fr"
        "GPaste@gnome-shell-extensions.gnome.org"
        "onedrive@client.onedrive.com"
        "blur-my-shell@aunetx"
        "luminus-shell-y@dikasp.gitlab"
      ];
      favorite-apps = [
        "chromium-browser.desktop"
        "org.keepassxc.KeePassXC.desktop"
        "code.desktop"
        "org.gnome.Nautilus.desktop"
        "com.raggesilver.BlackBox.desktop"
      ];
    };
  };

  home.stateVersion = "24.11";
}

