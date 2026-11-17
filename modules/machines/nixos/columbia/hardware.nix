{ lib, pkgs, ... }:
{
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

  systemd.services.radeon-resume-display = {
    description = "Restore Radeon display after resume";
    wantedBy = [
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
      "suspend-then-hibernate.target"
    ];
    after = [
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
      "suspend-then-hibernate.target"
    ];
    path = [
      pkgs.kbd
      pkgs.coreutils
    ];
    serviceConfig = {
      Type = "oneshot";
      TimeoutStartSec = 15;
    };
    script = ''
      sleep 1
      active_vt=$(fgconsole)
      spare_vt=$(fgconsole --next-available)
      if [ "$active_vt" = "$spare_vt" ] || [ "$spare_vt" -le 0 ]; then
        exit 0
      fi
      trap 'chvt "$active_vt"' EXIT
      chvt "$spare_vt"
      sleep 1
    '';
  };
  nix.settings = {
    max-jobs = 1;
    cores = 2;
  };
}
