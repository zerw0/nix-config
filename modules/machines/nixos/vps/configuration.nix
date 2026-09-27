{
  config,
  pkgs,
  inputs,
  ...
}:
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
  age.secrets.headscaleOidcSecret = {
    file = "${inputs.secrets}/headscaleOidcSecret.age";
    owner = "headscale";
  };
  homelab.services.headscale = {
    enable = true;
    nameservers = [
      "10.0.1.1"
      "1.1.1.1"
    ];
    oidc = {
      enable = true;
      clientId = "e3c2f28f-3b84-4eca-9ddd-743b60a1111b";
      clientSecretFile = config.age.secrets.headscaleOidcSecret.path;
    };
    policy = {
      tagOwners."tag:private" = [ "group:admin" ];
      groups = {
        "group:admin" = [ "hdjenkov@" ];
        "group:family" = [
          "georgieva@"
          "acid@"
          "lstoilov@"
          "m1rt0c1r9@"
          "petrovv@"
        ];
      };
      hosts = {
        zenit = "10.0.1.10/32";
        hass = "10.0.1.202/32";
        router = "10.0.1.1/32";
      };
      acls = [
        {
          action = "accept";
          src = [ "group:admin" ];
          dst = [ "*:*" ];
        }
        {
          action = "accept";
          src = [ "group:family" ];
          dst = [ "zenit:443" ];
        }
        {
          action = "accept";
          src = [ "group:family" ];
          dst = [ "hass:443,8123" ];
        }
        {
          action = "accept";
          src = [ "group:family" ];
          dst = [ "router:53" ];
        }
        {
          action = "accept";
          src = [ "group:family" ];
          dst = [ "autogroup:internet:*" ];
        }
        {
          action = "accept";
          src = [ "group:family" ];
          dst = [ "autogroup:self:*" ];
        }
      ];
    };
  };
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
      "immich.chopapi.xyz" = {
        port = 7001;
      };
      "nc.chopapi.xyz" = {
        port = 7002;
        caddyExtra = ''
          redir /.well-known/caldav  https://nc.chopapi.xyz/remote.php/dav/ 301
          redir /.well-known/carddav https://nc.chopapi.xyz/remote.php/dav/ 301
        '';
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
  homelab.services.motd.enable = true;
  homelab.services.fmbot = {
    enable = true;
    secretsFile = config.age.secrets.fmbotEnv.path;
  };
}
