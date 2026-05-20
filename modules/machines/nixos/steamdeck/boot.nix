{ ... }:
{
  # Jovian sets boot.kernelPackages to the Valve/Jovian kernel when
  # jovian.devices.steamdeck.enable = true — do not override it here.
  boot.loader = {
    timeout = 0;
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };
}
