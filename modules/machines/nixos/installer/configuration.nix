{ pkgs, inputs, ... }:
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
  ];

  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" ];

  services.openssh.settings = {
    LoginGraceTime = 0;
    PermitRootLogin = "no";
  };

  environment.systemPackages = with pkgs; [
    git
    rsync
    zsh
    neovim
    curl
    rxvt-unicode
  ];

  system.stateVersion = "25.11";
}
