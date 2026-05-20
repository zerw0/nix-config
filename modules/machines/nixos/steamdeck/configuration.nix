{ config, pkgs, inputs, ... }:
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

  jovian.devices.steamdeck.enable = true;
  jovian.devices.steamdeck.autoUpdate = true;
  jovian.steam = {
    enable = true;
    autoStart = true;
    user = "hdjenkov";
    desktopSession = "plasma";
  };
  jovian.decky-loader.enable = true;

  services.desktopManager.plasma6.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  age.secrets.hashedUserPassword.file = "${inputs.secrets}/hashedUserPassword.age";
  users.users.hdjenkov.hashedPasswordFile = config.age.secrets.hashedUserPassword.path;

  environment.systemPackages = with pkgs; [ prismlauncher ghostty.terminfo ];
}
