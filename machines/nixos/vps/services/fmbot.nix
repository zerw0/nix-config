{ config, ... }:
{
  virtualisation.oci-containers.containers.fmbot = {
    image = "git.zerw.xyz/hdjenkov/fmatrix:latest";
    environmentFiles = [ config.age.secrets.fmbotEnv.path ];
    environment = {
      PYTHONUNBUFFERED = "1";
    };
    volumes = [ "/var/lib/fmbot:/data" ];
    extraOptions = [ "--network=host" ];
    log-driver = "journald";
  };
}
