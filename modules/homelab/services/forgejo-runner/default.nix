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
    systemd.tmpfiles.rules = [ "d /var/lib/forgejo-runner 0750 1000 1000 -" ];
    virtualisation.oci-containers.containers = {
      docker-in-docker = {
        image = "docker:29.9.0-dind@sha256:0a02e01c20ef73e6060775ba3e33e415d289af3bfcf5b1b60e95674beb894875";
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
        image = "code.forgejo.org/forgejo/runner:13.2.0@sha256:68fbd60b1198116506b4cb65c63c17c65b26548932131447bb1a8ad7afb1e774";
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
