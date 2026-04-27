{ pkgs, lib, ... }:
{
  nix.settings.trusted-users = [ "hdjenkov" ];

  users.users.hdjenkov = lib.mkMerge [
    {
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = import ./keys.nix;
    }
    (lib.mkIf pkgs.stdenv.isDarwin {
      name = "hdjenkov";
      home = "/Users/hdjenkov";
    })
    (lib.mkIf (!pkgs.stdenv.isDarwin) {
      isNormalUser = true;
      group = "hdjenkov";
      extraGroups = [
        "wheel"
        "video"
        "audio"
        "input"
      ];
    })
  ];

  users.groups = lib.mkIf (!pkgs.stdenv.isDarwin) {
    hdjenkov = { };
  };

  programs.zsh.enable = true;
}
