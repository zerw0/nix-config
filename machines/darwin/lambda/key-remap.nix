{ config, pkgs, ... }:

{
  launchd.user.agents."com.local.KeyRemapping" = {
    serviceConfig = {
      Label = "com.local.KeyRemapping";
      ProgramArguments = [
        "/usr/bin/hidutil"
        "property"
        "--set"
        ''{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000035,"HIDKeyboardModifierMappingDst":0x700000064},{"HIDKeyboardModifierMappingSrc":0x700000064,"HIDKeyboardModifierMappingDst":0x700000035}]}''
      ];
      RunAtLoad = true;
      StandardOutPath = "/tmp/com.local.KeyRemapping.out";
      StandardErrorPath = "/tmp/com.local.KeyRemapping.err";
    };
  };
}
