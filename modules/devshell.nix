{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem =
    { config, pkgs, ... }:
    {
      treefmt = {
        projectRootFile = "flake.nix";
        programs = {
          nixfmt.enable = true;
          deadnix.enable = true;
          statix.enable = true;
          shellcheck.enable = true;
        };
      };

      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          just
          jq
          nh
          statix
          nixd
          zsh
          inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
        shellHook = ''
          export SHELL=${pkgs.zsh}/bin/zsh
        '';
      };

      devShells.web = pkgs.mkShell {
        inputsFrom = [ config.devShells.default ];
        packages = with pkgs; [
          nodejs
          pnpm
          typescript
          typescript-language-server
          vscode-langservers-extracted
        ];
      };
      devShells.go = pkgs.mkShell {
        inputsFrom = [ config.devShells.default ];
        packages = with pkgs; [
          go
          golangci-lint
          gopls
        ];
      };
      devShells.python = pkgs.mkShell {
        inputsFrom = [ config.devShells.default ];
        packages = [
          pkgs.basedpyright
          (pkgs.python313.withPackages (
            ps: with ps; [
              requests
              pyyaml
              pyopenssl
              python-dateutil
              hcloud
              ipykernel
            ]
          ))
        ];
      };
      devShells.infra = pkgs.mkShell {
        inputsFrom = [ config.devShells.default ];
        packages = with pkgs; [
          ansible
          hcloud
          opentofu
          openbao
          yaml-language-server
          terraform-ls
        ];
      };
    };
}
