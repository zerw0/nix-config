{
  inputs,
  lib,
  config,
  ...
}:
{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Hristo Djenkov";
        email = "me@zerw.xyz";
      };
      core = {
        sshCommand = "ssh -o 'IdentitiesOnly=yes' -i ~/.ssh/personal";
      };
    };
  };
}
