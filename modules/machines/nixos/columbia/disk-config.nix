{ lib, ... }:
let
  mountOptions = [
    "compress=zstd:1"
    "noatime"
  ];
  subvolume = mountpoint: { inherit mountpoint mountOptions; };
in
{
  disko.devices.disk.main = {
    type = "disk";
    device = lib.mkDefault "/dev/disk/by-id/ata-TEAM_T253LE240G_115E070303CD00011568";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
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
            subvolumes = {
              "@root" = subvolume "/";
              "@home" = subvolume "/home";
              "@nix" = subvolume "/nix";
              "@log" = subvolume "/var/log";
              "@cache" = subvolume "/var/cache";
              "@containers" = subvolume "/var/lib/docker";
              "@vms" = subvolume "/var/lib/libvirt/images";
              "@snapshots" = subvolume "/.snapshots";
              "@home-snapshots" = subvolume "/home/.snapshots";
            };
          };
        };
      };
    };
  };

  fileSystems."/nix".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;
  # Compressed RAM swap comes from _common. No disk swap / hibernation.
}
