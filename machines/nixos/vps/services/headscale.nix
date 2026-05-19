{ ... }:
{
  # Disabled until data is restored — enable after rsync of /var/lib/headscale
  # services.headscale = {
  #   enable = true;
  #   address = "0.0.0.0";
  #   port = 8080;
  #   settings = {
  #     server_url = "https://hs.zerw.xyz";
  #     dns.base_domain = "ts.zerw.xyz";
  #     log.level = "info";
  #   };
  # };
  # networking.firewall.allowedTCPPorts = [ 8080 ];
}
