{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./disk-config.nix
    ./boot.nix
    ./networking.nix
  ];

  system.stateVersion = "26.11";

  # Publishing so CUPS queues are discoverable as AirPrint targets, resolving
  # so Home Assistant can find devices. allowInterfaces is left unset to cover
  # both the wired and the wireless interface.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
      # Required for CUPS to advertise its shared queues over DNS-SD.
      userServices = true;
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      80 # Caddy, redirects to 443
      443 # Caddy
      631 # CUPS: IPP + web interface
      1883 # Mosquitto, for Frigate on Unraid
      8080 # scanservjs web UI
      8123 # Home Assistant
    ];
    allowedUDPPorts = [
      631 # CUPS browsing
      1900 # SSDP, for Home Assistant device discovery
      5353 # mDNS
    ];
  };

  virtualisation.podman.enable = true;
  virtualisation.podman.dockerSocket.enable = true;
  virtualisation.oci-containers.backend = "podman";

  # --all is deliberate: bumping a pinned tag leaves the old image tagged
  # rather than dangling, so a default prune would never reclaim it. Images
  # backing a running container are not touched.
  virtualisation.podman.autoPrune = {
    enable = true;
    dates = "weekly";
    flags = [ "--all" ];
  };

  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  age.secrets.hashedUserPassword.file = "${inputs.secrets}/hashedUserPassword.age";
  age.secrets.mosquittoHassPassword.file = "${inputs.secrets}/mosquittoHassPassword.age";
  age.secrets.mosquittoFrigatePassword.file = "${inputs.secrets}/mosquittoFrigatePassword.age";
  age.secrets.cloudflareApiToken.file = "${inputs.secrets}/cloudflareApiToken.age";
  users.users.hdjenkov.hashedPasswordFile = config.age.secrets.hashedUserPassword.path;

  homelab.enable = true;
  homelab.cloudflare.dnsCredentialsFile = config.age.secrets.cloudflareApiToken.path;

  # LAN-only names with real certs: Caddy issues via the Cloudflare DNS-01
  # challenge, so nothing here is reachable from the internet. Resolution comes
  # from a DNS override on the router, not from public records.
  homelab.services.caddy.enable = true;

  homelab.services.printing.enable = true;
  homelab.services.scanning = {
    enable = true;
    url = "scan.chopapi.xyz";
  };
  homelab.services.home-assistant = {
    enable = true;
    url = "hass.chopapi.xyz";
  };
  homelab.services.glances.enable = true;

  homelab.services.kiosk = {
    enable = true;
    url = "http://127.0.0.2:8123/server-stats/servers?kiosk";
  };

  homelab.services.mosquitto = {
    enable = true;
    hassPasswordFile = config.age.secrets.mosquittoHassPassword.path;
    frigatePasswordFile = config.age.secrets.mosquittoFrigatePassword.path;
  };

  environment.systemPackages = [ pkgs.ghostty.terminfo ];
}
