{
    pkgs,
    lib,
    inputs,
    ...
}:
{
  programs.spicetify =
  let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  in
  {
    enable = true;
    theme = spicePkgs.themes.onepunch;
  };
}
