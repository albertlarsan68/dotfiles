# bootstrap.nix
# Designed as first-boot configuration (bootstrap) for impermanence systems
# Run nixos-generate-config --root=/mnt for hardware scan then overwrite with this as configuration.nix
# Then you can reboot and get SecureBoot, TPM, /persist, and whatever else set up and use flakes to install
{ pkgs, lib, ... }: {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.supportedFilesystems = [ "btrfs" "ntfs" ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.enableAllFirmware = true;

  # Enable networking
  networking.hostName = "tmp";
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.utf8";

  # Enable the GNOME Desktop Environment with wayland.
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = true;
    desktopManager.gnome.enable = true;
    xkb.layout = "fr";
    xkb.variant = "";
  };

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.alarsan68 = {
    isNormalUser = true;
    description = "Albert Larsan";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox-wayland
      bind
      keepassxc
      vscode
      git
      starship
      pfetch
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    appimage-run
    neovim
    kakoune
    gcc
    gnupg
    sbctl
    tpm2-tss
    git
    gnome-tweaks
    gpaste
    gnomeExtensions.night-theme-switcher
  ];

  fonts.packages = with pkgs; [
    ibm-plex
    merriweather
    noto-fonts
    noto-fonts-emoji
  ];

  # Add env vars
  environment.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";
    NIXOS_OZONE_WL = "1";
  };

  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;

  services.gnome.gnome-keyring.enable = lib.mkForce false;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  system.stateVersion = "24.11";

  nix.settings.experimental-features = "nix-command flakes";

}
