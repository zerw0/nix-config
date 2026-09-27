{ pkgs, ... }:
{
  networking.hostName = "hass";
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;
  hardware.enableRedistributableFirmware = true;
  networking.networkmanager.wifi.powersave = false;

  environment.systemPackages = with pkgs; [
    iw
    wirelesstools
  ];
}
