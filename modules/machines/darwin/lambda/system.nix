{ ... }:
{
  system.defaults = {
    NSGlobalDomain.ApplePressAndHoldEnabled = false;

    dock = {
      orientation = "bottom";
      autohide = false;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.5;
      magnification = true;
      tilesize = 32;
      largesize = 64;
      wvous-tl-corner = 2;
      wvous-br-corner = 14;
    };

    trackpad.Clicking = true;

    finder = {
      ShowHardDrivesOnDesktop = false;
      ShowExternalHardDrivesOnDesktop = false;
      ShowRemovableMediaOnDesktop = false;
      ShowMountedServersOnDesktop = false;
      NewWindowTarget = "Home";
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      FXRemoveOldTrashItems = true;
      _FXSortFoldersFirst = true;
      _FXSortFoldersFirstOnDesktop = true;
      FXDefaultSearchScope = "SCcf";
      ShowPathbar = true;
    };
  };
}
