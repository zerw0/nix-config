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
          shellcheck.enable = true;
        };
      };

      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          just
          nh
          nixos-rebuild
          inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
      };
    };
}
