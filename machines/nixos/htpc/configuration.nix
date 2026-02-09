{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./filesystems.nix
  ];

  # Basic system configuration
  system.stateVersion = "25.11";

  # Locale and timezone
  time.timeZone = "Europe/Sofia";
  i18n.defaultLocale = "en_US.UTF-8";

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "htpc";
  networking.networkmanager.enable = true;

  # SSH
  services.openssh.enable = true;

  # Firewall
  networking.firewall = {
    allowedTCPPorts = [ 8080 ];
    allowedUDPPorts = [ 8080 ];
  };

  # Wayland and Cage for Kodi
  services.cage.enable = true;
  services.cage.user = "hdjenkov";
  services.cage.program = "${pkgs.kodi-wayland}/bin/kodi-standalone";

  # Sound with PipeWire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    fsType = "btrfs";
    options = [ "subvol=log" "compress=zstd" "noatime" ];
  };

  # User configuration
  users.users.hdjenkov = {
    isNormalUser = true;
    hashedPassword = "";
    extraGroups = [
      "wheel"  # for sudo
      "video"  # for GPU access
      "audio"  # for audio
    ];
  };
}
