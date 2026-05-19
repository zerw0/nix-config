{ config, ... }:
{
  virtualisation.oci-containers.containers.pocket-id = {
    image = "ghcr.io/pocket-id/pocket-id:latest";
    environment = {
      APP_URL = "https://id.zerw.xyz";
      TRUST_PROXY = "true";
      PUID = "1000";
      PGID = "1000";
    };
    environmentFiles = [ config.age.secrets.pocketIdEncryptionKey.path ];
    volumes = [ "/var/lib/pocket-id/data:/app/data" ];
    extraOptions = [ "--network=host" ];
  };
}
