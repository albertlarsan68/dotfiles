# git.nix
{ lib, pkgs, ... }: {

  programs.git.enable = lib.mkDefault true;
  programs.git.package = lib.mkDefault pkgs.gitAndTools.gitFull;
  programs.git.userName = lib.mkDefault "Albert Larsan";
  programs.git.userEmail = lib.mkDefault "albertlarsan@albertlarsan.fr";
  programs.git.signing.key = lib.mkDefault "key::sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMnUlaku3VnrDbhErcWNdc5HlAKeW4MD1xGwNqv1gAy8AAAABHNzaDo=";
  programs.git.signing.signByDefault = lib.mkDefault true;
  programs.git.extraConfig.init.defaultBranch = "main";
  programs.git.extraConfig.core.editor = "nvim";
  programs.git.extraConfig.color.ui = "always";
  programs.git.extraConfig.stash.showPatch = true;
  programs.git.extraConfig.pull.ff = "only";
  programs.git.extraConfig.push.autoSetupRemote = true;

}

