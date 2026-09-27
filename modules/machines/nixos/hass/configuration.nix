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
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
      userServices = true;
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      80
      443
      631
      1883
      8080
      8123
    ];
    allowedUDPPorts = [
      631
      1900
      5353
    ];
  };

  virtualisation.podman.enable = true;
  virtualisation.podman.dockerSocket.enable = true;
  virtualisation.oci-containers.backend = "podman";
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
