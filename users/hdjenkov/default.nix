{ username, inputs, pkgs, ... }:

{
  home-manager.users.hdjenkov.imports = [
    inputs.nixvim.homeModules.nixvim
    ../../dots/shell
    ../../dots/fastfetch
    ../../gitconfig.nix
    ../../dots/nvim
  ];

  # Home Manager release compatibility
  home-manager.users.hdjenkov.home.stateVersion = "25.11";

  # User packages
  home-manager.users.hdjenkov.home.packages = [
    pkgs.nerd-fonts.caskaydia-cove
  ];

  # Managed files / dotfiles
  home-manager.users.hdjenkov.home.file = {
    # ".screenrc".source = dotfiles/screenrc;
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  home-manager.users.hdjenkov.xdg.configFile."karabiner/karabiner.json".force = true;
  home-manager.users.hdjenkov.xdg.configFile."karabiner/karabiner.json".text = ''
    {
      "global": {
        "show_in_menu_bar": true
      },
      "profiles": [
        {
          "name": "Default profile",
          "selected": true,
          "simple_modifications": [
            {
              "from": { "key_code": "grave_accent_and_tilde" },
              "to": [{ "key_code": "non_us_backslash" }]
            },
            {
              "from": { "key_code": "non_us_backslash" },
              "to": [{ "key_code": "grave_accent_and_tilde" }]
            }
          ],
          "complex_modifications": {
            "rules": [
              {
                "description": "Caps Lock to Control when held, Escape when tapped",
                "manipulators": [
                  {
                    "type": "basic",
                    "from": { "key_code": "caps_lock" },
                    "to": [{ "key_code": "left_control" }],
                    "to_if_alone": [{ "key_code": "escape" }]
                  }
                ]
              }
            ]
          },
          "devices": [],
          "virtual_hid_keyboard": { "keyboard_type": "ansi" }
        }
      ]
    }
  '';

  # Session variables
  home-manager.users.hdjenkov.home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Let Home Manager manage itself
  home-manager.users.hdjenkov.programs.home-manager.enable = true;
}
