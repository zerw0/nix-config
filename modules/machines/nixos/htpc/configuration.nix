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

  system.stateVersion = "25.11";

  networking.hostName = "htpc";
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    allowInterfaces = [ "eno1" ];
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

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

  services.pulseaudio.enable = false;
  services.pipewire.enable = false;

  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "${myKodi}/bin/kodi-standalone";
        user = "hdjenkov";
      };
      default_session = {
        command = "${pkgs.greetd}/bin/agreety --cmd sway";
      };
    };
  };
  services.getty.autologinUser = "hdjenkov";

  programs.sway = {
    enable = true;
    xwayland.enable = false;
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    (_final: prev: {
      intel-vaapi-driver = prev.intel-vaapi-driver.override { enableHybridCodec = true; };
    })
  ];

  # Intel i915 needs the Skylake DMC firmware for display power management.
  hardware.firmware = [ pkgs.linux-firmware ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      libvdpau-va-gl
    ];
  };

  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  age.secrets.hashedUserPassword.file = "${inputs.secrets}/hashedUserPassword.age";
  users.users.hdjenkov.hashedPasswordFile = config.age.secrets.hashedUserPassword.path;

  environment.systemPackages = [
    pkgs.ffmpeg
    myKodi
    pkgs.ghostty.terminfo
  ];
}
