{ ... }:
{
  virtualisation.oci-containers.containers.epicgames-freegames = {
    image = "charlocharlie/epicgames-freegames:latest";
    volumes = [ "/var/lib/epicgames-freegames:/usr/app/config" ];
    extraOptions = [ "--network=host" ];
  };
}
