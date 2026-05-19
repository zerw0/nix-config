{ ... }:
{
  virtualisation.oci-containers.containers.gerbil = {
    image = "docker.io/fosrl/gerbil:1.3.1";
    dependsOn = [ "pangolin" ];
    cmd = [
      "--reachableAt=http://gerbil:3004"
      "--generateAndSaveKeyTo=/var/config/key"
      "--remoteConfig=http://pangolin:3001/api/v1/"
    ];
    volumes = [ "/var/lib/pangolin:/var/config" ];
    ports = [
      "51820:51820/udp"
      "21820:21820/udp"
      "443:443"
      "80:80"
    ];
    extraOptions = [
      "--network=pangolin-net"
      "--cap-add=NET_ADMIN"
      "--cap-add=SYS_MODULE"
    ];
  };
}
