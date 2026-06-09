{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  options.dots.dev-tools.enable = lib.mkEnableOption "developer CLI toolchain (nix, node, go, python, ansible, glab, awscli, agenix)";

  config = lib.mkIf config.dots.dev-tools.enable {
    home.packages = with pkgs; [
      nodejs
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
      inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
      (python313.withPackages (
        ps: with ps; [
          pip
          setuptools
          requests
          pyyaml
          pyopenssl
          ansible-core
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
