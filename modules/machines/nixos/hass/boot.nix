{ pkgs, ... }:
{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    consoleLogLevel = 0;
    initrd = {
      verbose = false;
    };
    kernelParams = [
      "quiet"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "boot.shell_on_fail"
    ];
    loader = {
      timeout = 3;
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        # 512M ESP: bound the retained generations so old kernels and initrds
        # cannot fill /boot.
        configurationLimit = 10;
      };
    };
  };
}
