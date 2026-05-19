{ lib, ... }:
{
  imports = [ ./services ];

  options.homelab = {
    enable = lib.mkEnableOption "homelab";

    baseDomain = lib.mkOption {
      type = lib.types.str;
      default = "zerw.xyz";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "hdjenkov";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "users";
    };

    timeZone = lib.mkOption {
      type = lib.types.str;
      default = "Europe/Sofia";
    };

    cloudflare.dnsCredentialsFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the file containing CLOUDFLARE_API_TOKEN.";
    };
  };
}
