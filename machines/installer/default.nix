{ pkgs, inputs, lib, ... }:

{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "hdjenkov" ];
  };

  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" ];
  i18n.defaultLocale = "en_US.UTF-8";

  security.sudo.wheelNeedsPassword = false;

  users.users.hdjenkov = {
    isNormalUser = true;
    shell = pkgs.zsh;
    group = "hdjenkov";
    extraGroups = [ "wheel" "video" "audio" "input" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHggBw49Gg0kyKKp2H44rqhlBEH1z1RdYPQIAU7AJiWe me@zerw.xyz"
    ];
  };

  users.groups.hdjenkov = { };

  environment.systemPackages = with pkgs; [
    git
    rsync
    zsh
    neovim
    wget
    curl
    rxvt-unicode
  ];

  programs.zsh.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      LoginGraceTime = 0;
      PermitRootLogin = "no";
    };
  };

  system.stateVersion = "25.05";
}
