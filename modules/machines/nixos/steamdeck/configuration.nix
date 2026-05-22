{ config, lib, pkgs, inputs, ... }:
{
  imports = [
    inputs.jovian.nixosModules.default
    inputs.nix-flatpak.nixosModules.nix-flatpak
    ./disk-config.nix
    ./boot.nix
    ./tailscale.nix
  ];

  system.stateVersion = "25.11";

  networking.hostName = "steamdeck";
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;

  jovian.devices.steamdeck = {
    enable = true;
    autoUpdate = true;
    enableGyroDsuService = true;
  };
  jovian.steamos.useSteamOSConfig = true;
  jovian.hardware.has.amd.gpu = true;

  programs.steam = {
    enable = true;
    protontricks.enable = true;
    remotePlay.openFirewall = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  hardware.steam-hardware.enable = true;

  # The gamescope session embeds a direct reference to pkgs.steam, which is
  # built without programs.steam.extraPackages. Steam's controller firmware
  # updater needs libhidapi; without it the OOBE firmware check fails and
  # blocks first-run setup. Inject hidapi at the package level so the session
  # steam picks it up too. (steamdeck_stable client lacks Valve's vendored fix.)
  nixpkgs.overlays = [
    (final: prev: {
      steam = prev.steam.override (old: {
        extraPkgs = pkgs: (old.extraPkgs or (_: [ ]) ) pkgs ++ [ pkgs.hidapi ];
        extraLibraries = pkgs: (old.extraLibraries or (_: [ ]) ) pkgs ++ [ pkgs.hidapi ];
      });
    })
  ];

  jovian.steam = {
    enable = true;
    autoStart = true;
    user = "hdjenkov";
    desktopSession = "plasma";
    environment.STEAM_EXTRA_COMPAT_TOOLS_PATHS =
      lib.makeSearchPathOutput "steamcompattool" "" config.programs.steam.extraCompatPackages;
  };

  jovian.decky-loader = {
    enable = true;
    user = "hdjenkov";
    stateDir = "/home/hdjenkov/.local/share/decky";
    extraPackages = with pkgs; [
      gawk curl unzip util-linux gnugrep readline procps pciutils
      flatpak libpulseaudio
    ];
    extraPythonPackages = p: [ p.click ];
  };

  services.desktopManager.plasma6.enable = true;

  # Flatpak backend for KDE Discover, with declarative management via nix-flatpak.
  services.flatpak.enable = true;
  services.flatpak.remotes = [{
    name = "flathub";
    location = "https://flathub.org/repo/flathub.flatpakrepo";
  }];
  services.flatpak.packages = [
    "org.telegram.desktop"
    "im.riot.Riot"
    "com.spotify.Client"
    "com.bitwarden.desktop"
    "org.libreoffice.LibreOffice"
    "org.localsend.localsend_app"
    "org.filezillaproject.Filezilla"
    "org.kde.haruna"
    "fr.handbrake.ghb"
    "org.qbittorrent.qBittorrent"
    "com.github.iwalton3.jellyfin-media-player"
    "eu.betterbird.Betterbird"
    "dev.vencord.Vesktop"
    "in.cinny.Cinny"
    "com.rustdesk.RustDesk"
    "com.anydesk.Anydesk"
    "com.github.Eloston.UngoogledChromium"
  ];
  # PackageKit backend for Discover. Limited on NixOS (declarative system), but
  # lets Discover surface offline/firmware updates and the flatpak backend.
  services.packagekit.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    wayland.compositor = "kwin";
  };

  programs.xwayland.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  hardware.cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;
  hardware.bluetooth.enable = true;
  hardware.sensor.iio.enable = true;

  nixpkgs.config.allowUnfree = true;

  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  age.secrets.hashedUserPassword.file = "${inputs.secrets}/hashedUserPassword.age";
  users.users.hdjenkov.hashedPasswordFile = config.age.secrets.hashedUserPassword.path;

  services.syncthing = {
    enable = true;
    user = "hdjenkov";
    dataDir = "/home/hdjenkov";
    openDefaultPorts = true;
  };

  environment.systemPackages = with pkgs; [ prismlauncher ghostty.terminfo steamdeck-firmware ];
}
