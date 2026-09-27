{ inputs, ... }:
{
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  age.secrets = {
    pocketIdEncryptionKey = {
      file = "${inputs.secrets}/pocketIdEncryptionKey.age";
    };
    fmbotEnv = {
      file = "${inputs.secrets}/fmbotEnv.age";
    };
    frpsToken = {
      file = "${inputs.secrets}/frpsToken.age";
    };
    cloudflareApiToken = {
      file = "${inputs.secrets}/cloudflareApiToken.age";
    };
  };
}
