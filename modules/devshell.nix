{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem =
    { pkgs, ... }:
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
          inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
      };

      devShells.web = pkgs.mkShell {
        packages = with pkgs; [
          nodejs
          pnpm
        ];
      };
      devShells.go = pkgs.mkShell {
        packages = with pkgs; [
          go
          golangci-lint
        ];
      };
      devShells.python = pkgs.mkShell {
        packages = [
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
        packages = with pkgs; [
          ansible
          hcloud
          opentofu
          openbao
        ];
      };
    };
}
