{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dots.cloud-tools.enable = lib.mkEnableOption "cloud/infra CLI toolchain (hcloud, opentofu, openbao, lefthook)";

  config = lib.mkIf config.dots.cloud-tools.enable {
    home.packages = with pkgs; [
      hcloud
      opentofu
      openbao
      lefthook
      lazyssh
    ];
  };
}
