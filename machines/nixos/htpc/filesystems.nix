{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/3a3ac575-4ff3-426e-8680-2603abf81817";
    fsType = "btrfs";
    options = [
      "subvol=root"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/7126-CB80";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/3a3ac575-4ff3-426e-8680-2603abf81817";
    fsType = "btrfs";
    options = [
      "subvol=home"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/3a3ac575-4ff3-426e-8680-2603abf81817";
    fsType = "btrfs";
    options = [
      "subvol=nix"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-uuid/3a3ac575-4ff3-426e-8680-2603abf81817";
    fsType = "btrfs";
    options = [
      "subvol=log"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-uuid/d5d5f79f-c584-45f9-86c9-14440ea78eb7";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  fileSystems."/var/lib" = {
    device = "/dev/disk/by-uuid/3a3ac575-4ff3-426e-8680-2603abf81817";
    fsType = "btrfs";
    options = [
      "subvol=lib"
      "compress=zstd"
      "noatime"
    ];
    neededForBoot = true;
  };
}
