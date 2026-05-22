{ lib, config, inputs, ... }:
let
  cfg = config.modules.tailscale;
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
      authKeyFile = cfg.authKeyFile;
      extraUpFlags = [ "--login-server=${cfg.loginServer}" "--reset" ];
      extraSetFlags = lib.optional (cfg.acceptRoutes || cfg.subnetRouter) "--accept-routes"
        ++ lib.optionals cfg.subnetRouter [
          "--advertise-routes=${lib.concatStringsSep "," cfg.advertiseRoutes}"
        ] ++ lib.optional cfg.exitNode "--advertise-exit-node";
    };

    boot.kernel.sysctl = lib.mkIf (cfg.subnetRouter || cfg.exitNode) {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
  };
}
