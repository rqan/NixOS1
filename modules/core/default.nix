{ config, lib, pkgs, ... }:

{
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Filesystems & Mounts
  boot.supportedFilesystems = [ "ntfs" "exfat" "btrfs" ];
  services.udisks2.enable = true;
  services.gvfs.enable = true;

  # Time & Locale
  time.timeZone = "Asia/Jakarta";
  i18n.defaultLocale = "en_US.UTF-8";

  # Networking
  services.resolved.enable = true;
  services.resolved.settings.Resolve = {
    DNS = "127.0.0.1:5300";
    Domains = [ "~test" ];
  };
  networking = {
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
    };
  };

  # Printing & Power
  services.printing.enable = true;
  services.upower.enable = true;
  services.logind.settings.Login.HandlePowerKey = "ignore";

  # Sound with PipeWire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # RAM Optimization
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  # Security & Keyring
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
  security.pam.services.login.enableGnomeKeyring = true;
  security.rtkit.enable = true;

  # User Configuration
  users.users.focarix = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "input" "kvm" ];
    initialPassword = "908";
  };

  # Nix & Nixpkgs
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "26.05";
}
