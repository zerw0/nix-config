{ ... }:
{
  # Jovian sets boot.kernelPackages to the Valve/Jovian kernel when
  # jovian.devices.steamdeck.enable = true — do not override it here.
  boot = {
    kernelModules = [ "kvm-amd" ];
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "usbhid"
      "sdhci_pci"
    ];
    loader = {
      timeout = 0;
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = 30;
      };
    };
  };
}
