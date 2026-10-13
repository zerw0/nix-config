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
      address = "0.0.0.0";
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
      reverse_proxy 127.0.0.1:8080
    '';
  };
}
