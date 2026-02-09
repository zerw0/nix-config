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

  # Kodi
  services.xserver.enable = true;
  services.xserver.desktopManager.kodi.enable = true;
  services.displayManager.autoLogin.user = "hdjenkov";
  services.xserver.displayManager.lightdm.greeter.enable = false;

  # Define a user account
  users.extraUsers.hdjenkov.isNormalUser = true;

  # Sound with PipeWire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Shell
  programs.fish.enable = true;
  users.users.hdjenkov.shell = pkgs.fish;

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
