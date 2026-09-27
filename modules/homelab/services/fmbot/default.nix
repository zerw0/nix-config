{
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.homelab.services.fmbot;
in
{
  imports = [
    (
      {
        config,
        lib,
        pkgs,
        ...
      }:
      import "${inputs.fmatrix}/module.nix" {
        inherit config lib;
        fmatrix = pkgs.callPackage "${inputs.fmatrix}/package.nix" { };
      }
    )
  ];

  options.homelab.services.fmbot = {
    enable = lib.mkEnableOption "FMBot (Last.fm Discord bot)";
    secretsFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the agenix-decrypted env file for fmbot.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.fmatrix = {
      enable = true;
      matrix.homeserver = "https://chat.notthebe.ee";
      matrix.userId = "@fmbot:notthebe.ee";
      secretsFile = cfg.secretsFile;
    };
  };
}
