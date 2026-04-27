{ config, ... }:
{
  programs.git = {
    enable = true;
    settings.user.name = "Hristo Djenkov";
    settings.user.email = "me@zerw.xyz";
    settings.core.sshCommand =
      "ssh -o IdentitiesOnly=yes -i ${config.home.homeDirectory}/.ssh/personal";
  };
}
