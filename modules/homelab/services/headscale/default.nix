{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.homelab.services.headscale;
  runtimeConfig =
    if cfg.manageConfigInHeadplane then
      "/var/lib/headscale/config/server.yaml"
    else
      toString config.services.headscale.configFile;
  unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
  };
  # Separate from the website's nginx so this ingress can be validated and
  # reloaded independently. Limits apply to HTTP/Noise handshakes, not the
  # encrypted registration messages inside an established Noise connection.
  ingressConfig = pkgs.writeText "headscale-ingress.conf" ''
    pid /run/headscale-ingress/nginx.pid;
    error_log stderr warn;
    events { worker_connections 1024; }
    http {
      access_log off;
      client_body_temp_path /run/headscale-ingress/body;
      proxy_temp_path /run/headscale-ingress/proxy;
      map $http_upgrade $headscale_connection {
        default upgrade;
        "" close;
      }
      map $uri $headscale_handshake_ip {
        default "";
        /key $binary_remote_addr;
        /ts2021 $binary_remote_addr;
      }
      map $uri $headscale_handshake_global {
        default "";
        /key headscale;
        /ts2021 headscale;
      }
      limit_req_zone $headscale_handshake_ip zone=handshake_ip:1m rate=2r/s;
      limit_req_zone $headscale_handshake_global zone=handshake_global:1m rate=10r/s;
      limit_conn_zone $binary_remote_addr zone=connections_ip:1m;
      limit_conn_zone $server_name zone=connections_global:1m;
      server {
        listen 127.0.0.1:8082;
        server_name ${cfg.url};
        # Caddy overwrites this header with the actual TCP peer address.
        set_real_ip_from 127.0.0.1;
        real_ip_header X-Headscale-Client-IP;
        client_max_body_size 1m;
        client_header_timeout 10s;
        client_body_timeout 10s;
        limit_req_status 429;
        limit_conn_status 429;
        limit_req zone=handshake_ip burst=32 nodelay;
        limit_req zone=handshake_global burst=64 nodelay;
        limit_conn connections_ip 32;
        limit_conn connections_global 256;
        location / {
          proxy_pass http://127.0.0.1:8080;
          proxy_http_version 1.1;
          proxy_set_header Host $http_host;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection $headscale_connection;
          proxy_set_header X-Forwarded-For $remote_addr;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-Proto https;
          proxy_buffering off;
          proxy_request_buffering off;
          proxy_read_timeout 1d;
          proxy_send_timeout 1d;
        }
      }
    }
  '';
in
{
  options.homelab.services.headscale = {
    enable = lib.mkEnableOption "Headscale";
    url = lib.mkOption {
      type = lib.types.str;
      default = "hs.${config.homelab.baseDomain}";
    };
    baseDomain = lib.mkOption {
      type = lib.types.str;
      default = "ts.${config.homelab.baseDomain}";
      description = "Tailscale magic DNS base domain.";
    };
    oidc = {
      enable = lib.mkEnableOption "OIDC authentication (via pocket-id)";
      issuer = lib.mkOption {
        type = lib.types.str;
        default = "https://id.${config.homelab.baseDomain}";
      };
      clientId = lib.mkOption {
        type = lib.types.str;
        description = "OIDC client ID registered in pocket-id.";
      };
      clientSecretFile = lib.mkOption {
        type = lib.types.path;
        description = "Path to the agenix-decrypted OIDC client secret.";
      };
    };

    nameservers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "1.1.1.1"
        "1.0.0.1"
      ];
      description = ''
        Nameservers pushed to every tailnet client. override_local_dns is on,
        so these fully replace the client's own resolvers. Pointing these at a
        LAN resolver makes all tailnet DNS depend on that host being reachable
        over the tailnet.
      '';
    };

    policy = lib.mkOption {
      type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
      default = null;
      description = ''
        Headscale ACL policy (policy v2), rendered to JSON at
        /etc/headscale/policy.json. In database mode this imports the policy
        once, replacing any old database policy; subsequent changes are
        managed in Headplane.
        Null means no policy, which is allow-all in file mode.
        Note that policy v2 requires usernames to carry a trailing "@".
      '';
    };

    policyMode = lib.mkOption {
      type = lib.types.enum [
        "file"
        "database"
      ];
      default = "file";
      description = "Use database mode to manage ACLs through Headplane.";
    };

    manageConfigInHeadplane = lib.mkEnableOption "persistent DNS and settings management through Headplane";
  };

  config = lib.mkIf cfg.enable {
    services.headscale = {
      enable = true;
      # Upstream 0.29.5 fixes exit-node policy propagation; nixpkgs is still on 0.29.4.
      package = unstable.headscale.overrideAttrs (
        final: _previous: {
          version = "0.29.5";
          src = pkgs.fetchFromGitHub {
            owner = "juanfont";
            repo = "headscale";
            tag = "v${final.version}";
            hash = "sha256-Uyf4JvZoANwWNqw6JCoRn7Z4ZQxh+hVJVB6SBPkVEv0=";
          };
          vendorHash = "sha256-sdSDAIBaW5c9eTgZfFSrn8LEqHg37Hnr1PszuoXPm6Y=";
        }
      );
      address = "127.0.0.1";
      port = 8080;
      settings = {
        server_url = "https://${cfg.url}";
        dns = {
          base_domain = cfg.baseDomain;
          nameservers.global = cfg.nameservers;
        };
        log.level = "info";
        policy = {
          mode = cfg.policyMode;
          path = lib.mkIf (cfg.policyMode == "file" && cfg.policy != null) "/etc/headscale/policy.json";
        };
        oidc = lib.mkIf cfg.oidc.enable {
          issuer = cfg.oidc.issuer;
          client_id = cfg.oidc.clientId;
          client_secret_path = cfg.oidc.clientSecretFile;
          scope = [
            "openid"
            "profile"
            "email"
          ];
          pkce = {
            enabled = true;
            method = "S256";
          };
        };
      };
    };

    environment.etc."headscale/policy.json" = lib.mkIf (cfg.policy != null) {
      text = builtins.toJSON cfg.policy;
      user = "headscale";
      mode = "0400";
    };

    # Environment overrides also cover the persistent Headplane-managed YAML.
    # Bound resource damage; these are containment, not an upstream bug fix.
    systemd.services.headscale = {
      environment = {
        HEADSCALE_LISTEN_ADDR = "127.0.0.1:8080";
        HEADSCALE_DERP_SERVER_ENABLED = "false";
        GOMEMLIMIT = "384MiB";
      };
      serviceConfig = {
        MemoryHigh = "384M";
        MemoryMax = "512M";
        MemorySwapMax = "0";
        OOMPolicy = "stop";
        Restart = "always";
        RestartSec = "5s";
      };
    };

    systemd.services.headscale-ingress = {
      description = "Rate-limited Headscale ingress";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
        "headscale.service"
      ];
      wants = [ "headscale.service" ];
      serviceConfig = {
        ExecStartPre = "${pkgs.nginx}/bin/nginx -t -c ${ingressConfig} -p /run/headscale-ingress";
        ExecStart = "${pkgs.nginx}/bin/nginx -c ${ingressConfig} -p /run/headscale-ingress -g 'daemon off;'";
        DynamicUser = true;
        RuntimeDirectory = "headscale-ingress";
        Restart = "always";
        RestartSec = "5s";
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_UNIX"
        ];
        MemoryMax = "128M";
        TasksMax = 16;
      };
    };

    # Retire the scoped live mitigation when a full NixOS activation takes over.
    system.activationScripts.retireHeadscaleTailwormOverrides = {
      deps = [ "etc" ];
      text = ''
        rm -f /etc/systemd/system.control/headscale.service.d/50-tailworm.conf
        rm -f /etc/systemd/system.control/headscale-ingress.service
        rm -f /etc/systemd/system.control/multi-user.target.d/50-tailworm.conf
        if test -d /var/lib/tailworm-mitigation; then
          ln -sfn /etc/static/caddy/caddy_config /etc/caddy/caddy_config
          rm -f /nix/var/nix/gcroots/tailworm-headscale-ingress
          rm -f /nix/var/nix/gcroots/tailworm-headscale-service
          rm -f /nix/var/nix/gcroots/tailworm-headscale-caddy
        fi
      '';
    };

    # Import before the server starts, so stale database policies never activate.
    # Preserve policies subsequently saved through Headplane.
    systemd.services.headscale.preStart = lib.mkMerge [
      (lib.mkIf cfg.manageConfigInHeadplane (
        lib.mkBefore ''
          install -d -m 0750 /var/lib/headscale/config
          if ! test -e ${runtimeConfig}; then
            install -m 0600 ${config.services.headscale.configFile} ${runtimeConfig}
            cp ${runtimeConfig} /var/lib/headscale/server-config-before-headplane.yaml
          fi
        ''
      ))
      (lib.mkIf (cfg.policyMode == "database") ''
        policy_marker=/var/lib/headscale/.database-policy-initialized
        if ! test -e "$policy_marker"; then
          policy_error=$(mktemp)
          trap 'rm -f "$policy_error"' EXIT
          if ${lib.getExe config.services.headscale.package} --config ${runtimeConfig} --force policy get \
            --bypass-grpc-and-access-database-directly \
            > /var/lib/headscale/policy-before-import.json 2>"$policy_error"; then
            :
          elif ! ${pkgs.gnugrep}/bin/grep -Fq 'acl policy not found' "$policy_error"; then
            cat "$policy_error" >&2
            exit 1
          fi
          ${lib.getExe config.services.headscale.package} --config ${runtimeConfig} --force policy check \
            --bypass-grpc-and-access-database-directly --file /etc/headscale/policy.json
          ${lib.getExe config.services.headscale.package} --config ${runtimeConfig} --force policy set \
            --bypass-grpc-and-access-database-directly --file /etc/headscale/policy.json
          touch "$policy_marker"
        else
          ${lib.getExe config.services.headscale.package} --config ${runtimeConfig} --force policy get \
            --bypass-grpc-and-access-database-directly >/dev/null
        fi
      '')
    ];

    systemd.services.headscale.script = lib.mkIf cfg.manageConfigInHeadplane (
      lib.mkForce ''
        ${lib.optionalString (config.services.headscale.settings.database.postgres.password_file != null) ''
          export HEADSCALE_DATABASE_POSTGRES_PASS="$(head -n1 ${lib.escapeShellArg config.services.headscale.settings.database.postgres.password_file})"
        ''}
        exec ${lib.getExe config.services.headscale.package} serve --config ${runtimeConfig}
      ''
    );

    systemd.paths.headscale-config = lib.mkIf cfg.manageConfigInHeadplane {
      description = "Watch Headplane-managed Headscale settings";
      wantedBy = [ "multi-user.target" ];
      after = [ "headscale.service" ];
      pathConfig = {
        PathChanged = runtimeConfig;
        Unit = "headscale-config-reload.service";
      };
    };

    systemd.services.headscale-config-reload = lib.mkIf cfg.manageConfigInHeadplane {
      description = "Validate and apply Headplane-managed Headscale settings";
      serviceConfig.Type = "oneshot";
      path = [ pkgs.systemd ];
      script = ''
        ${lib.getExe config.services.headscale.package} --config ${runtimeConfig} configtest
        systemctl restart headscale.service
      '';
    };

    assertions = [
      {
        assertion = cfg.policyMode != "database" || cfg.policy != null;
        message = "Headscale database policy mode requires an initial policy.";
      }
    ];

    services.caddy.virtualHosts.${cfg.url}.extraConfig = ''
      handle /admin* {
        reverse_proxy 127.0.0.1:3002
      }
      reverse_proxy 127.0.0.1:8082 {
        header_up X-Headscale-Client-IP {remote_host}
      }
    '';
  };
}
