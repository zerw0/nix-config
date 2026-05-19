{ inputs, config, ... }:
{
  imports = [ inputs.fmatrix.nixosModules.default ];

  services.fmatrix = {
    enable = true;
    matrix.homeserver = "https://chat.notthebe.ee";
    matrix.userId = "@fmbot:notthebe.ee";
    secretsFile = config.age.secrets.fmbotEnv.path;
  };
}
