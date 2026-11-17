{ lib, pkgs, ... }:
{
  # Sandy Bridge i5-2520M: use the cached, supported LTS kernel rather than
  # rebuilding the entire package set with CPU-specific compiler flags.
  boot.kernelPackages = pkgs.linuxPackages_6_18;
  boot.initrd.availableKernelModules = [
    "ahci"
    "ehci_pci"
    "xhci_pci"
    "usb_storage"
    "sd_mod"
    "sr_mod"
    "sdhci_pci"
  ];
  boot.initrd.kernelModules = [ "radeon" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 10;
    efi.canTouchEfiVariables = true;
    timeout = 5;
  };

  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    # HD 6470M uses the kernel's radeon driver and Mesa's r600 driver.
  };
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;

  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "ondemand";
      CPU_SCALING_GOVERNOR_ON_BAT = "ondemand";
      CPU_BOOST_ON_BAT = 0;
      RADEON_DPM_STATE_ON_BAT = "battery";
      RADEON_POWER_PROFILE_ON_BAT = "low";
    };
  };
  services.thermald.enable = true;
  services.fstrim.enable = true;
  # Keep build pressure manageable on the 2-core / 4-thread CPU.
  nix.settings = {
    max-jobs = 1;
    cores = 2;
  };
}
