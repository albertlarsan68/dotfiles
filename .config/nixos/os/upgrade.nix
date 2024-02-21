# upgrade.nix
{ lib, ... }: {

  # Enable automatic upgrades through this flake repository
  system.autoUpgrade.enable = lib.mkDefault true;
  system.autoUpgrade.flake = lib.mkDefault "github:kjhoerr/dotfiles";

  # Since automatic updates are enabled, automatically gc older generations
  # To note, this will gc home-manager user profiles as well
  nix.gc.automatic = lib.mkDefault true;
  nix.gc.options = lib.mkDefault "--delete-older-than 14d";

  # Enable nix-community public binary cache, for potential build skips on flakes
  nix.settings.substituters = lib.mkDefault [ "https://nix-community.cachix.org" "https://cache.nixos.org/" ];
  nix.settings.trusted-public-keys = lib.mkDefault [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
  nix.settings.trusted-users = lib.mkDefault [ "root" "@wheel" ];

  # Leave SSHD off by default, but set up sensible defaults for when it's enabled
  services.openssh.enable = lib.mkDefault false;
  services.openssh.settings = {
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
  };

  # Similar to SSHD config, leave off by default but add personal pubkey
  nix.sshServe.enable = lib.mkDefault false;
  nix.sshServe.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEVH5c050+fT7lIYhycEVvbDx6+aNeDliEFTNLP2EULk openpgp:0x69ED7111" ];

  # Disable network targets due to common upgrade issues
  systemd = {
    targets.network-online.wantedBy = lib.mkForce []; # Normally ["multi-user.target"]
    services.NetworkManager-wait-online.wantedBy = lib.mkForce []; # Normally ["network-online.target"]
  };
}
