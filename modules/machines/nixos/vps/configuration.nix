{ config, pkgs, inputs, ... }:
{
  imports = [
    ./hardware.nix
    ./disk-config.nix
    ./boot.nix
    ./networking.nix
    ./tailscale.nix
    ./secrets.nix
  ];

  system.stateVersion = "25.11";

  age.secrets.hashedUserPassword.file = "${inputs.secrets}/hashedUserPassword.age";
  users.users.hdjenkov.hashedPasswordFile = config.age.secrets.hashedUserPassword.path;

  virtualisation.podman.enable = true;
  virtualisation.podman.dockerSocket.enable = true;
  virtualisation.oci-containers.backend = "podman";

  environment.systemPackages = [ pkgs.ghostty.terminfo ];

  homelab.enable = true;
  homelab.cloudflare.dnsCredentialsFile = config.age.secrets.cloudflareApiToken.path;

  homelab.services.caddy.enable = true;
  homelab.services.postgresql.enable = true;
  homelab.services.forgejo.enable = true;
  homelab.services.forgejo-runner.enable = true;
  homelab.services.headscale.enable = true;
  homelab.services.headplane.enable = true;
  homelab.services.pocket-id = {
    enable = true;
    encryptionKeyFile = config.age.secrets.pocketIdEncryptionKey.path;
  };
  homelab.services.uptime-kuma.enable = true;
  homelab.services.frps = {
    enable = true;
    tokenFile = config.age.secrets.frpsToken.path;
    tunneledHosts = {
      "immich.chopapi.xyz" = { port = 7001; };
      "nc.chopapi.xyz" = {
        port = 7002;
        extraConfig = ''
          header_up X-Forwarded-For {remote_host}
          header_up X-Forwarded-Proto {scheme}
          header_up X-Real-IP {remote_host}
          transport http {
            tls
            tls_insecure_skip_verify
          }'';
      };
    };
  };
  homelab.services.website.enable = true;
  homelab.services.epicgames-freegames.enable = true;
  homelab.services.fmbot = {
    enable = true;
    secretsFile = config.age.secrets.fmbotEnv.path;
  };
}
