{ config, pkgs, ... }:

{
  # Deploy key remapping Launch Agent (swaps Caps Lock and Right Option via hidutil)
  home.file."/Library/LaunchDaemons/com.local.KeyRemapping.plist" = {
    text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
          <key>Label</key>
          <string>com.local.KeyRemapping</string>
          <key>ProgramArguments</key>
          <array>
              <string>/usr/bin/hidutil</string>
              <string>property</string>
              <string>--set</string>
              <string>{"UserKeyMapping":[
                  {
                    "HIDKeyboardModifierMappingSrc": 0x700000035,
                    "HIDKeyboardModifierMappingDst": 0x700000064
                  },
                  {
                    "HIDKeyboardModifierMappingSrc": 0x700000064,
                    "HIDKeyboardModifierMappingDst": 0x700000035
                  }
              ]}</string>
          </array>
          <key>RunAtLoad</key>
          <true/>
      </dict>
      </plist>
    '';
  };
}
