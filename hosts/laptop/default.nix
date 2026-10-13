{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/core
    ../../modules/desktop
    ../../modules/programs
  ];

  networking.hostName = "focarix";

  # Intel Graphics Hardware Acceleration
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    intel-vaapi-driver
  ];

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  # ASUS Battery Charge Limit (80%)
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", KERNEL=="BAT0", ATTR{charge_control_end_threshold}="80"
  '';

  systemd.services.asus-battery-charge-threshold = {
    description = "Set ASUS battery charge threshold to 80%";
    wantedBy = [ "multi-user.target" "post-resume.target" ];
    after = [ "multi-user.target" "post-resume.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'echo 80 > /sys/class/power_supply/BAT0/charge_control_end_threshold'";
    };
  };
}
