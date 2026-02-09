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
  services.openssh.settings.PasswordAuthentication = false;

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

  # Sound with PipeWire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # User configuration
  users.users.hdjenkov = {
    isNormalUser = true;
    hashedPassword = "";
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHggBw49Gg0kyKKp2H44rqhlBEH1z1RdYPQIAU7AJiWe me@zerw.xyz"
    ];
    extraGroups = [
      "wheel"  # for sudo
      "video"  # for GPU access
      "audio"  # for audio
    ];
  };

  # Shell
  programs.fish.enable = true;
}
