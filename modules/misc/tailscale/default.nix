{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.modules.tailscale;
  unstable = import inputs.nixpkgs-unstable { inherit (pkgs.stdenv.hostPlatform) system; };
in
{
  options.modules.tailscale = {
    enable = lib.mkEnableOption "Tailscale";

    authKeyFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the agenix-decrypted Tailscale auth key file.";
    };

    loginServer = lib.mkOption {
      type = lib.types.str;
      default = "https://hs.zerw.xyz";
    };

    acceptRoutes = lib.mkEnableOption "accept routes from subnet routers";

    acceptDns = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Accept the nameservers headscale pushes. Set false on hosts that must
        keep resolving independently of the tailnet - notably the VPS, whose
        ACME renewals would otherwise depend on the home router being up.
      '';
    };

    subnetRouter = lib.mkEnableOption "subnet router";
    exitNode = lib.mkEnableOption "exit node advertisement";

    advertiseRoutes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "192.168.0.0/24" ];
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets.tailscaleAuthKey.file = "${inputs.secrets}/tailscaleAuthKey.age";

    services.tailscale = {
      enable = true;
      package = unstable.tailscale;
      inherit (cfg) authKeyFile;
      extraUpFlags = [
        "--login-server=${cfg.loginServer}"
        "--reset"
      ];
      extraSetFlags = [
        "--accept-dns=${lib.boolToString cfg.acceptDns}"
      ]
      ++ lib.optional (cfg.acceptRoutes || cfg.subnetRouter) "--accept-routes"
      ++ lib.optionals cfg.subnetRouter [
        "--advertise-routes=${lib.concatStringsSep "," cfg.advertiseRoutes}"
      ]
      ++ lib.optional cfg.exitNode "--advertise-exit-node";
    };

    boot.kernel.sysctl = lib.mkIf (cfg.subnetRouter || cfg.exitNode) {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
  };
}
