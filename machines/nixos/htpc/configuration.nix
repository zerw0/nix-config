{
  config,
  pkgs,
  inputs,
  ...
}:
let
  myKodi = pkgs.kodi-gbm.withPackages (p: with p; [ jellycon ]);
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
  networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;

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

  environment.systemPackages = [
    myKodi
    pkgs.ghostty.terminfo
  ];

  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  age.secrets.hashedUserPassword.file = "${inputs.secrets}/hashedUserPassword.age";
  users.users.hdjenkov.hashedPasswordFile = config.age.secrets.hashedUserPassword.path;
  security.sudo.wheelNeedsPassword = false;
  security.sudo.extraConfig = "Defaults env_keep+=SSH_AUTH_SOCK";

  # BTRFS scrub
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
  };

  # Nix GC
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.settings.auto-optimise-store = true;

  # Log rotation
  services.journald.extraConfig = ''
    SystemMaxUse=500M
    MaxRetentionSec=1week
  '';

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
  nixpkgs.overlays = [
    (final: prev: {
      intel-vaapi-driver = prev.intel-vaapi-driver.override { enableHybridCodec = true; };
    })
  ];

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
