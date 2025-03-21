# spruce-frame.nix
{ pkgs, ... }: {

  networking.hostName = "spruce-frame";

  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
      kernelModules = [ "dm-snapshot" "tpm_crb" ];

      luks.devices."enc" = {
        device = "/dev/disk/by-uuid/6b8a5b1c-9cd5-4e25-a713-bba1e90ecaf5";
        preLVM = true;
      };
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/5767338b-cc2e-43f3-8e07-f31c82a42345";
      fsType = "btrfs";
      options = [ "subvol=root" "compress=zstd" "noatime" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/5767338b-cc2e-43f3-8e07-f31c82a42345";
      fsType = "btrfs";
      options = [ "subvol=home" "compress=zstd" "noatime" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/5767338b-cc2e-43f3-8e07-f31c82a42345";
      fsType = "btrfs";
      options = [ "subvol=nix" "compress=zstd" "noatime" ];
    };

  fileSystems."/persist" =
    { device = "/dev/disk/by-uuid/5767338b-cc2e-43f3-8e07-f31c82a42345";
      fsType = "btrfs";
      options = [ "subvol=persist" "compress=zstd" "noatime" ];
      neededForBoot = true;
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-uuid/5767338b-cc2e-43f3-8e07-f31c82a42345";
      fsType = "btrfs";
      options = [ "subvol=log" "compress=zstd" "noatime" ];
      neededForBoot = true;
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/C464-D756";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/e0126018-1442-4e0f-9a48-81af5aa0778d"; }
    ];

  nixpkgs.hostPlatform = "x86_64-linux";

  services.tailscale.enable = true;
  networking.firewall.checkReversePath = "loose";

  # Enable LVFS testing to get UEFI updates
  services.fwupd.extraRemotes = [ "lvfs-testing" ];

  # User accounts
  users.mutableUsers = false;
  users.users.root.hashedPasswordFile = "/persist/passwords/root";
  users.users.alarsan68 = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Albert Larsan";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "podman" ];
    hashedPasswordFile = "/persist/passwords/alarsan68";
  };

  environment.systemPackages = with pkgs; [
    fw-ectool
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

  nix.settings.experimental-features = "nix-command flakes";
}
