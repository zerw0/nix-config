{ pkgs, ... }:
{
  virtualisation.oci-containers.containers = {
    docker-in-docker = {
      image = "docker:dind";
      cmd = [ "dockerd" "-H" "tcp://0.0.0.0:2375" "--tls=false" ];
      environment = { };
      extraOptions = [
        "--privileged"
        "--network=forgejo-net"
      ];
      volumes = [ ];
    };

    forgejo-runner = {
      image = "code.forgejo.org/forgejo/runner:9.0.3";
      dependsOn = [ "docker-in-docker" ];
      cmd = [ "/bin/sh" "-c" "sleep 5; forgejo-runner daemon --config /config.yaml" ];
      environment = {
        DOCKER_HOST = "tcp://docker-in-docker:2375";
      };
      user = "1000:1000";
      extraOptions = [
        "--privileged"
        "--network=forgejo-net"
      ];
      volumes = [
        "/var/lib/forgejo-runner:/data"
        "/var/lib/forgejo-runner/config.yaml:/config.yaml"
      ];
    };
  };

  # Create the shared network before containers start
  systemd.services.init-forgejo-net = {
    description = "Create podman network for forgejo runner";
    before = [ "podman-docker-in-docker.service" "podman-forgejo-runner.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [ pkgs.podman ];
    script = ''
      podman network exists forgejo-net || podman network create forgejo-net
    '';
  };
}
