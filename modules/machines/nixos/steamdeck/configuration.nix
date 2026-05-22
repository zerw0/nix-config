{ config, lib, pkgs, inputs, ... }:
{
  imports = [
    inputs.jovian.nixosModules.default
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

  environment.systemPackages = with pkgs; [ prismlauncher ghostty.terminfo steamdeck-firmware ];
}
