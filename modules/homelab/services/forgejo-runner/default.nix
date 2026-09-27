{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.homelab.services.forgejo-runner;
in
{
  options.homelab.services.forgejo-runner = {
    enable = lib.mkEnableOption "Forgejo Runner";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      docker-in-docker = {
        image = "docker:dind";
        cmd = [
          "dockerd"
          "-H"
          "tcp://0.0.0.0:2375"
          "--tls=false"
        ];
        extraOptions = [
          "--privileged"
          "--network=forgejo-net"
        ];
      };

      forgejo-runner = {
        image = "code.forgejo.org/forgejo/runner:12.10.1";
        dependsOn = [ "docker-in-docker" ];
        cmd = [
          "/bin/sh"
          "-c"
          "sleep 5; forgejo-runner daemon --config /config.yaml"
        ];
        environment.DOCKER_HOST = "tcp://docker-in-docker:2375";
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

    systemd.services.init-forgejo-net = {
      description = "Create podman network for forgejo runner";
      before = [
        "podman-docker-in-docker.service"
        "podman-forgejo-runner.service"
      ];
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
  };
}
