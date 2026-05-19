{
  disko.devices = {
    disk = {
      storage = {
        type = "disk";
        device = "/dev/sdb";
        content = {
          type = "gpt";
          partitions = {
            STORAGE = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/mnt/storage";
              };
            };
          };
        };
      };
      main = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Override existing partition
                # Subvolumes must set a mountpoint in order to be mounted,
                # unless their parent is mounted
                subvolumes = {
                  # Subvolume name is different from mountpoint
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "subvol=root"
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  # Subvolume name is the same as the mountpoint
                  "/home" = {
                    mountOptions = [
                      "subvol=home"
                      "compress=zstd"
                      "noatime"
                    ];
                    mountpoint = "/home";
                  };
                  # Parent is not mounted so the mountpoint must be set
                  "/nix" = {
                    mountOptions = [
                      "subvol=nix"
                      "compress=zstd"
                      "noatime"
                    ];
                    mountpoint = "/nix";
                  };
                  "/log" = {
                    mountpoint = "/var/log";
                    mountOptions = [
                      "subvol=log"
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/lib" = {
                    mountpoint = "/var/lib";
                    mountOptions = [
                      "subvol=lib"
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                };

              };
            };
          };
        };
      };
    };
  };
  fileSystems."/var/log".neededForBoot = true;
  fileSystems."/var/lib".neededForBoot = true;
}
