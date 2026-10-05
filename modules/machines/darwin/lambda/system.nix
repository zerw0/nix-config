{ pkgs, ... }:
{
  system.startup.chime = false;

  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
  ];

  system.defaults = {
    NSGlobalDomain = {
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      AppleShowAllExtensions = true;
      AppleShowScrollBars = "Always";
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSDocumentSaveNewDocumentsToCloud = false;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      NSTableViewDefaultSizeMode = 2;
      NSUseAnimatedFocusRing = false;
      NSWindowResizeTime = 1.0e-3;
      PMPrintingExpandedStateForPrint = true;
      PMPrintingExpandedStateForPrint2 = true;
      "com.apple.sound.beep.feedback" = 0;
      NSWindowShouldDragOnGesture = true;
      AppleMeasurementUnits = "Centimeters";
      AppleMetricUnits = 1;
      AppleTemperatureUnit = "Celsius";
    };

    dock = {
      orientation = "bottom";
      autohide = false;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.5;
      magnification = true;
      tilesize = 32;
      largesize = 64;
      mru-spaces = false;
      show-recents = false;
      minimize-to-application = true;
      expose-animation-duration = 0.1;
      launchanim = false;
      wvous-tl-corner = 2;
      wvous-br-corner = 14;
    };

    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
    };

    finder = {
      ShowHardDrivesOnDesktop = false;
      ShowExternalHardDrivesOnDesktop = false;
      ShowRemovableMediaOnDesktop = false;
      ShowMountedServersOnDesktop = false;
      NewWindowTarget = "Home";
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      FXEnableExtensionChangeWarning = false;
      FXRemoveOldTrashItems = true;
      _FXSortFoldersFirst = true;
      _FXSortFoldersFirstOnDesktop = true;
      FXDefaultSearchScope = "SCcf";
      ShowPathbar = true;
      ShowStatusBar = true;
      QuitMenuItem = true;
      FXPreferredViewStyle = "Nlsv";
      _FXShowPosixPathInTitle = true;
    };

    loginwindow = {
      GuestEnabled = false;
      DisableConsoleAccess = true;
    };

    screensaver = {
      askForPassword = true;
      askForPasswordDelay = 0;
    };

    menuExtraClock.Show24Hour = true;

    screencapture = {
      location = "~/Pictures/Screenshots";
      type = "png";
      disable-shadow = true;
    };

    spaces.spans-displays = false;

    WindowManager = {
      EnableStandardClickToShowDesktop = true;
      StandardHideDesktopIcons = false;
    };
    CustomUserPreferences = {
      "com.apple.screencapture" = {
        show-thumbnail = false;
      };
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
      "com.apple.TextEdit" = {
        RichText = 0;
        SmartQuotes = 0;
        SmartDashes = 0;
      };
      "com.apple.Safari" = {
        IncludeDevelopMenu = true;
        IncludeInternalDebugMenu = true;
        WebKitDeveloperExtrasEnabledPreferenceKey = true;
      };
      "com.apple.DiskUtility" = {
        advanced-image-options = true;
        DUDebugMenuEnabled = true;
      };
      "com.apple.CrashReporter" = {
        DialogType = "none";
      };
      "com.apple.ImageCapture" = {
        disableHotPlug = true;
      };
      "com.apple.ActivityMonitor" = {
        IconType = 5;
        ShowCategory = 0;
      };
      "com.apple.HIToolbox" = {
        AppleEnabledInputSources = [
          {
            InputSourceKind = "Keyboard Layout";
            "KeyboardLayout ID" = 0;
            "KeyboardLayout Name" = "U.S.";
          }
          {
            InputSourceKind = "Keyboard Layout";
            "KeyboardLayout ID" = 19529;
            "KeyboardLayout Name" = "Bulgarian - Phonetic";
          }
        ];
      };
    };
  };
}
