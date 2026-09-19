{ pkgs, lib, ... }:
{
  nix.settings.trusted-users = lib.mkIf (!pkgs.stdenv.hostPlatform.isDarwin) [ "hdjenkov" ];

  users.users.hdjenkov = lib.mkMerge [
    {
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = import ./keys.nix;
    }
    (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      name = "hdjenkov";
      home = "/Users/hdjenkov";
    })
    (lib.mkIf (!pkgs.stdenv.hostPlatform.isDarwin) {
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

  users.groups = lib.mkIf (!pkgs.stdenv.hostPlatform.isDarwin) {
    hdjenkov = { };
  };

  programs.zsh.enable = true;
}
