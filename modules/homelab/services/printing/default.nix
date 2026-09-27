{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.homelab.services.printing;
in
{
  options.homelab.services.printing = {
    enable = lib.mkEnableOption "CUPS print server, shared to the LAN";

    port = lib.mkOption {
      type = lib.types.port;
      default = 631;
      description = "IPP and web-interface port.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.printing = {
      enable = true;
      drivers = [ pkgs.brlaser ];
      listenAddresses = [ "*:${toString cfg.port}" ];
      allowFrom = [ "all" ];
      browsing = true;
      defaultShared = true;
      webInterface = true;
      extraConf = ''
        DefaultEncryption Never
      '';
    };
  };
}
