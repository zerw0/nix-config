{ ... }:

{
  home-manager.users.hdjenkov.home.file.".config/karabiner/karabiner.json".text = ''
    {
      "global": {
        "check_for_updates_on_startup": true
      },
      "profiles": [
        {
          "name": "Default",
          "selected": true,
          "simple_modifications": [
            {
              "from": { "key_code": "grave_accent_and_tilde" },
              "to": [ { "key_code": "non_us_backslash" } ]
            },
            {
              "from": { "key_code": "non_us_backslash" },
              "to": [ { "key_code": "grave_accent_and_tilde" } ]
            }
          ],
          "complex_modifications": { "rules": [] },
          "devices": [],
          "fn_function_keys": [],
          "parameters": {
            "delay_milliseconds_before_open_device": 1000
          },
          "virtual_hid_keyboard": {
            "country_code": 0,
            "mouse_key_xy_scale": 100
          }
        }
      ]
    }
  '';
}
