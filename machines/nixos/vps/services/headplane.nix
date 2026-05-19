{ ... }:
{
  virtualisation.oci-containers.containers.headplane = {
    image = "ghcr.io/tale/headplane:latest";
    volumes = [
      "/var/lib/headplane/config.yaml:/etc/headplane/config.yaml"
      "/var/lib/headscale/config.yaml:/etc/headscale/config.yaml:ro"
      "/var/lib/headplane/data:/var/lib/headplane"
      "/run/podman/podman.sock:/var/run/docker.sock:ro"
    ];
    extraOptions = [ "--network=host" ];
  };
}
