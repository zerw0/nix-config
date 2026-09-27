{ config, ... }:
{
  programs.git = {
    enable = true;
    settings.user.name = "Hristo Djenkov";
    settings.user.email = "me@zerw.xyz";
    settings.core.sshCommand = "ssh -o IdentitiesOnly=yes -i ${config.home.homeDirectory}/.ssh/personal";
    settings.credential.helper = "osxkeychain";
    signing = {
      format = "ssh";
      key = "${config.home.homeDirectory}/.ssh/personal.pub";
      signByDefault = true;
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
      syntax-theme = "gruvbox-dark";
    };
  };
}
