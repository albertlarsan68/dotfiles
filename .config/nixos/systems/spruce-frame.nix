# spruce-frame.nix
{ pkgs, ... }: {

  networking.hostName = "spruce-frame";

  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "usbhid" "sd_mod" ];
      kernelModules = [ "dm-snapshot" "tpm_crb" ];

      luks.devices."enc" = {
        device = "/dev/disk/by-uuid/06574ecb-cbcf-48f3-8a23-a0068322e776";
        preLVM = true;
      };
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/2a95c3e2-e582-4163-bce5-7e45b51c3911";
      fsType = "btrfs";
      options = [ "subvol=root" "compress=zstd" "noatime" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/2a95c3e2-e582-4163-bce5-7e45b51c3911";
      fsType = "btrfs";
      options = [ "subvol=home" "compress=zstd" "noatime" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/2a95c3e2-e582-4163-bce5-7e45b51c3911";
      fsType = "btrfs";
      options = [ "subvol=nix" "compress=zstd" "noatime" ];
    };

  fileSystems."/persist" =
    { device = "/dev/disk/by-uuid/2a95c3e2-e582-4163-bce5-7e45b51c3911";
      fsType = "btrfs";
      options = [ "subvol=persist" "compress=zstd" "noatime" ];
      neededForBoot = true;
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-uuid/2a95c3e2-e582-4163-bce5-7e45b51c3911";
      fsType = "btrfs";
      options = [ "subvol=log" "compress=zstd" "noatime" ];
      neededForBoot = true;
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/C464-D756";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/ca446774-a211-4c30-86c7-2a39e314262e"; }
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
