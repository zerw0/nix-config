{ lib, pkgs, config, ... }:
let
  cfg = config.homelab.services.postgresql;
in
{
  options.homelab.services.postgresql = {
    enable = lib.mkEnableOption "PostgreSQL";
  };

  config = lib.mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      package = pkgs.postgresql_14;
    };
  };
}
