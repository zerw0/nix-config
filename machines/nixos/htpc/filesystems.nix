{
  fileSystems."/" = {
    device = "/dev/sda2";
    fsType = "btrfs";
    options = [
      "subvol=root"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/sda1";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  fileSystems."/home" = {
    device = "/dev/sda2";
    fsType = "btrfs";
    options = [
      "subvol=home"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/sda2";
    fsType = "btrfs";
    options = [
      "subvol=nix"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/var/log" = {
    device = "/dev/sda2";
    fsType = "btrfs";
    options = [
      "subvol=log"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/mnt/storage" = {
    device = "/dev/sdb1";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  fileSystems."/var/lib" = {
    device = "/dev/sda2";
    fsType = "btrfs";
    options = [
      "subvol=lib"
      "compress=zstd"
      "noatime"
    ];
    neededForBoot = true;
  };
}
