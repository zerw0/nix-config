{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./filesystems.nix
    ./boot.nix
    ./tailscale.nix
  ];

  # Basic system configuration
  system.stateVersion = "25.11";

  # Locale and timezone
  time.timeZone = "Europe/Sofia";
  i18n.defaultLocale = "en_US.UTF-8";

  # Networking
  networking.hostName = "htpc";
  networking.networkmanager.enable = true;

  # SSH
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  # ZRam
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # Avahi
  services.avahi = {
    enable = true;
    nssmdns4 = true; # Enable .local resolution for IPv4
    allowInterfaces = [ "eno1" ]; # Only announce on main ethernet (not podman/veth)
    publish = {
      enable = true;
      addresses = true; # Publish hostname.local
      workstation = true; # Announce as workstation
    };
  };

  # Firewall
  networking.firewall = {
    allowedTCPPorts = [
      8080
      5000
    ];
    allowedUDPPorts = [
      8080
      5353
    ];
  };

  # Kodi
  services.xserver.enable = true;
  services.xserver.desktopManager.kodi.enable = true;
  services.xserver.desktopManager.kodi.package = (
    pkgs.kodi.withPackages (
      kodiPkgs: with kodiPkgs; [
        jellyfin
      ]
    )
  );
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
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHggBw49Gg0kyKKp2H44rqhlBEH1z1RdYPQIAU7AJiWe me@zerw.xyz"
    ];
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "input"
    ];
  };

  # Hardware acceleration (Intel)
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      libvdpau-va-gl
    ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  # Shell
  programs.zsh.enable = true;
}
