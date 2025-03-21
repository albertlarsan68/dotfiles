{
  inputs = {
    nixos-pkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Secure Boot for NixOS
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixos-pkgs";
    };

    # User profile manager based on Nix
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Module for running NixOS as WSL2 instance
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixos-pkgs";
    };

    # Links persistent folders into system
    impermanence.url = "github:nix-community/impermanence";

    # Provides module support for specific vendor hardware
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # Zen Browser
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      lib = inputs.nixos-pkgs.lib;
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      guiOverlays = [
        (_: _: { zen-browser = inputs.zen-browser.packages.${system}.default; })
      ];

      # Base user config modules
      homeModules = [
        ./.config/nixos/home/tui.nix
        ./.config/nixos/home/git.nix
        ./.config/nixos/home/neovim.nix
        # ./.config/nixos/home/helix.nix
        ./.config/nixos/home/gpg-agent.nix
      ];

      # Additional user applications and configurations
      guiModules = [
        ./.config/nixos/home/applications.nix
        ./.config/nixos/home/gnome.nix
        ./.config/nixos/home/sway.nix
        {
          nixpkgs.overlays = guiOverlays;
        }
      ];

      # Base OS configs, adapts to system configs
      osModules = [
        inputs.lanzaboote.nixosModules.lanzaboote
        inputs.impermanence.nixosModules.impermanence
        inputs.nixos-hardware.nixosModules.common-hidpi
        ./.config/nixos/os/certs.nix
        ./.config/nixos/os/persist.nix
        ./.config/nixos/os/secure-boot.nix
        ./.config/nixos/os/system.nix
        ./.config/nixos/os/upgrade.nix
      ];

      # OS config modules for base WSL system
      wslModules = [
        "${inputs.nixos-pkgs}/nixos/modules/profiles/minimal.nix"
        inputs.nixos-wsl.nixosModules.wsl
        ./.config/nixos/os/certs.nix
        ./.config/nixos/os/upgrade.nix
      ];

      # Function to build a home configuration from user modules
      homeUser = (userModules: inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        # userModules overwrites, so is appended
        modules = homeModules ++ guiModules ++ userModules;
      });

      # Function to build a home configuration from user modules for WSL
      wslUser = (userModules: inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        # userModules overwrites, so is appended
        modules = homeModules ++ userModules;
      });

      # Function to build a nixos configuration from system modules
      nixosSystem = (systemModules: lib.nixosSystem {
        inherit system;
        # osModules depends on some values from systemModules, so is appended
        modules = systemModules ++ osModules;
      });

      # Function to build a nixos configuration for WSL
      wslSystem = (systemModules: lib.nixosSystem {
        inherit system;
        modules = systemModules ++ wslModules;
      });

    in {
      homeConfigurations = {

        alarsan68 = homeUser [ ./.config/nixos/users/alarsan68.nix ];

        # kjhoerr = homeUser [ ./.config/nixos/users/kjhoerr.nix ];

        nixos = wslUser [ ./.config/nixos/users/nixos.nix ];

      };
      nixosConfigurations = {
	spruce-frame = nixosSystem [
          inputs.nixos-hardware.nixosModules.framework-intel-core-ultra-series1
          ./.config/nixos/systems/spruce-frame.nix
        ];

        #ariadne = nixosSystem [
        #  inputs.nixos-hardware.nixosModules.framework-13-7040-amd
        #  ./.config/nixos/systems/ariadne.nix
        #];

        #cronos = nixosSystem [
        #  inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p1-gen3
        #  ./.config/nixos/systems/cronos.nix
        #];

        #whisker = nixosSystem [
        #  inputs.nixos-hardware.nixosModules.common-gpu-amd
        #  ./.config/nixos/systems/whisker.nix
        #];

        nixos-wsl = wslSystem [
          ./.config/nixos/systems/wsl.nix
          {
            users.users.nixos.extraGroups = lib.mkAfter [ "docker" ];
          }
        ];

      };
    };
}
