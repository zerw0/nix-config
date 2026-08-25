{ pkgs, ... }:
{
  networking.hostName = "hass";
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;

  # Wi-Fi works, but prefer Ethernet where possible: mDNS across a
  # Wi-Fi/Ethernet bridge is less reliable and many APs isolate wireless
  # clients by default, which breaks discovery without breaking ping.
  #
  # Most Intel/Realtek/MediaTek cards need the vendor blob before the wireless
  # interface appears at all.
  hardware.enableRedistributableFirmware = true;

  # Powersave parks the card between beacons, which delays the mDNS/SSDP that
  # AirPrint discovery and HA's integrations depend on.
  networking.networkmanager.wifi.powersave = false;

  environment.systemPackages = with pkgs; [
    iw
    wirelesstools
  ];
}
