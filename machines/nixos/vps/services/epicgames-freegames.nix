{ ... }:
{
  virtualisation.oci-containers.containers.epicgames-freegames = {
    image = "charlocharlie/epicgames-freegames:latest";
    environment.SERVER_PORT = "3010";
    volumes = [ "/var/lib/epicgames-freegames:/usr/app/config" ];
    extraOptions = [ "--network=host" ];
  };
}
