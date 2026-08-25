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
      631 # CUPS: IPP + web interface
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
  users.users.hdjenkov.hashedPasswordFile = config.age.secrets.hashedUserPassword.path;

  homelab.enable = true;
  homelab.services.printing.enable = true;
  homelab.services.scanning.enable = true;
  homelab.services.home-assistant.enable = true;

  environment.systemPackages = [ pkgs.ghostty.terminfo ];
}
