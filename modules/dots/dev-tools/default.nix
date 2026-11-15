{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  options.dots.dev-tools.enable = lib.mkEnableOption "developer CLI tools (nix, git, glab, gh, awscli, agenix)";

  config = lib.mkIf config.dots.dev-tools.enable {
    home.packages = with pkgs; [
      nixd
      glab
      awscli2
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

    # GitHub CLI. Sign in once with `gh auth login` (the token goes to the macOS
    # keychain); settings and the github.com git credential helper are managed here.
    programs.gh = {
      enable = true;
      settings = {
        git_protocol = "https";
        prompt = "enabled";
      };
    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
