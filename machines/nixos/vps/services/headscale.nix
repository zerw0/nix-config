{ ... }:
{
  services.headscale = {
    enable = true;
    address = "0.0.0.0";
    port = 8080;

    settings = {
      server_url = "https://hs.zerw.xyz";
      dns = {
        base_domain = "ts.zerw.xyz";
        nameservers.global = [ "1.1.1.1" "1.0.0.1" ];
      };
      log.level = "info";
    };
  };

  networking.firewall.allowedTCPPorts = [ 8080 ];
}
