# gpg-agent.nix
{ lib, pkgs, ... }:
let
  gpg-sshid-ctl = pkgs.writeShellApplication {
    name = "gpg-sshid-ctl";
    runtimeInputs = with pkgs; [ openssh gnupg ];
    text = builtins.readFile ../scripts/gpg-sshid-ctl.sh;
  };
in {

  programs.gpg.enable = lib.mkDefault true;
  programs.gpg.mutableKeys = lib.mkDefault false;
  programs.gpg.mutableTrust = lib.mkDefault false;
  programs.gpg.publicKeys = [
  ];

  # gnome-keyring is greedy and will override SSH_AUTH_SOCK where undesired
  services.gnome-keyring.enable = lib.mkDefault false;

  services.gpg-agent.enable = lib.mkDefault true;
  services.gpg-agent.enableSshSupport = lib.mkDefault false;
  services.gpg-agent.enableExtraSocket = lib.mkDefault true;

  home.packages = lib.mkAfter [ gpg-sshid-ctl ];

}

