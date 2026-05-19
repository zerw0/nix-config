{ ... }:
{
  virtualisation.oci-containers.containers.headplane = {
    image = "ghcr.io/tale/headplane:latest";
    volumes = [
      "/var/lib/headplane/config:/etc/headplane"
      "/etc/headscale:/etc/headscale:ro"
      "/var/run/podman/podman.sock:/var/run/docker.sock:ro"
    ];
    environment.PORT = "3002";
    extraOptions = [ "--network=host" ];
  };

}
