{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  options.dots.dev-tools.enable = lib.mkEnableOption "developer CLI toolchain (nix, node, pnpm, go, python, ansible, glab, awscli, agenix)";

  config = lib.mkIf config.dots.dev-tools.enable {
    home.packages = with pkgs; [
      nodejs
      pnpm
      ansible
      go
      golangci-lint
      nil
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
      bottom
      nh
      nix-output-monitor
      inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
      (python313.withPackages (
        ps: with ps; [
          requests
          pyyaml
          pyopenssl
          ansible
          python-dateutil
          hcloud
        ]
      ))
    ];

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
