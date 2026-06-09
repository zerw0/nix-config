{ ... }:
{
  imports = [ ../../_common-packages.nix ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  security.pam.services.sudo_local.touchIdAuth = true;
}
