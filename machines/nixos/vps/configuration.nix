{ config, pkgs, inputs, ... }:
{
  imports = [
    ./hardware.nix
    ./disk-config.nix
    ./boot.nix
    ./networking.nix
    ./tailscale.nix
    ./secrets.nix
    ./services
  ];

  system.stateVersion = "25.11";

  time.timeZone = "Europe/Sofia";
  i18n.defaultLocale = "en_US.UTF-8";

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.settings.auto-optimise-store = true;

  services.journald.extraConfig = ''
    SystemMaxUse=500M
    MaxRetentionSec=1week
  '';

  age.secrets.hashedUserPassword.file = "${inputs.secrets}/hashedUserPassword.age";
  users.users.hdjenkov.hashedPasswordFile = config.age.secrets.hashedUserPassword.path;
  security.sudo.wheelNeedsPassword = false;

  virtualisation.podman.enable = true;
  virtualisation.podman.dockerSocket.enable = true;
  virtualisation.oci-containers.backend = "podman";

  environment.systemPackages = [ pkgs.ghostty.terminfo ];
}
