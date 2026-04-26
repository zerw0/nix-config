{
  config,
  pkgs,
  inputs,
  ...
}:
let
  myKodi = pkgs.kodi-gbm.withPackages (p: with p; [ jellyfin ]);
in
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

  # Kodi GBM
  services.pulseaudio.enable = false;
  services.pipewire.enable = false;

  environment.systemPackages = [ myKodi ];

  users.users.hdjenkov.initialHashedPassword = "";

  services.getty.autologinUser = "hdjenkov";
  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "${myKodi}/bin/kodi-standalone";
        user = "hdjenkov";
      };
      default_session = {
        command = "${pkgs.greetd.greetd}/bin/agreety --cmd sway";
      };
    };
  };

  programs.sway = {
    enable = true;
    xwayland.enable = false;
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

}
