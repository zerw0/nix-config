{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  options.dots.dev-tools.enable = lib.mkEnableOption "developer CLI tools (nix, git, glab, awscli, agenix)";

  config = lib.mkIf config.dots.dev-tools.enable {
    home.packages = with pkgs; [
      nixd
      glab
      awscli
      pwgen
      age
      git-lfs
      iperf3
      just
      jq
      yq-go
      lazygit
      nh
      nix-output-monitor
      inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
