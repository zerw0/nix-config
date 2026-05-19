{ ... }:
{
  # nginx disabled — static site will be served through traefik/pangolin
  # Re-enable once traefik is routing correctly
  # services.nginx = {
  #   enable = true;
  #   virtualHosts."_" = {
  #     root = "/var/www/site";
  #   };
  # };
}
