{ pkgs, inputs, ... }:

{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
    ../../modules/common.nix
    ../../users/hdjenkov
  ];

  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" ];
  i18n.defaultLocale = "en_US.UTF-8";

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    git
    rsync
    zsh
    neovim
    curl
    rxvt-unicode
  ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      LoginGraceTime = 0;
      PermitRootLogin = "no";
    };
  };

  system.stateVersion = "25.11";
}
