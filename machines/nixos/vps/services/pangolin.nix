{ ... }:
{
  virtualisation.oci-containers.containers.pangolin = {
    image = "docker.io/fosrl/pangolin:1.18.2";
    volumes = [ "/var/lib/pangolin:/app/config" ];
    extraOptions = [ "--network=pangolin-net" ];
  };

  systemd.services.init-pangolin-net = {
    description = "Create podman network for pangolin stack";
    before = [
      "podman-pangolin.service"
      "podman-gerbil.service"
      "podman-traefik.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman network exists pangolin-net || podman network create pangolin-net
    '';
  };
}
