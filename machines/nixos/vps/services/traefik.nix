{ ... }:
{
  virtualisation.oci-containers.containers.traefik = {
    image = "docker.io/traefik:v3.6";
    dependsOn = [ "pangolin" "gerbil" ];
    cmd = [ "--configFile=/etc/traefik/traefik_config.yml" ];
    volumes = [
      "/var/lib/pangolin/traefik:/etc/traefik:ro"
      "/var/lib/pangolin/letsencrypt:/letsencrypt"
      "/var/lib/pangolin/logs:/var/log/traefik"
    ];
    # Share gerbil's network namespace so traefik binds on gerbil's ports
    extraOptions = [ "--network=container:gerbil" ];
  };
}
