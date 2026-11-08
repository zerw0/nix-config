{ lib, ... }:
let
  # Captured from the installed RemoveMacAI 1.1.4 app profile on 2026-11-08.
  # Keep its identifiers and UUIDs so approval replaces the existing profile.
  identifier = "io.github.omlahore.removemacai";
  restrictions = lib.genAttrs [
    "allowApplePersonalizedAdvertising"
    "allowAssistant"
    "allowBookstore"
    "allowDiagnosticSubmission"
    "allowExternalIntelligenceIntegrations"
    "allowExternalIntelligenceIntegrationsSignIn"
    "allowGameCenter"
    "allowGenmoji"
    "allowImagePlayground"
    "allowiPhoneMirroring"
    "allowMailSmartReplies"
    "allowMailSummary"
    "allowMusicService"
    "allowNotesTranscriptionSummary"
    "allowSafariSummary"
    "allowSpotlightInternetResults"
    "allowWritingTools"
  ] (_: false);
  preferences = {
    ".GlobalPreferences".NSAutomaticInlinePredictionEnabled = false;
    "com.apple.MobileAsset" = lib.genAttrs [
      "DownloadServerBaseURLOverride-com.apple.MobileAsset.UAF.FM.CodeLM"
      "DownloadServerBaseURLOverride-com.apple.MobileAsset.UAF.FM.GenerativeModels"
      "DownloadServerBaseURLOverride-com.apple.MobileAsset.UAF.FM.Visual"
      "DownloadServerBaseURLOverride-com.apple.MobileAsset.UAF.Photos.MagicCleanup"
      "DownloadServerBaseURLOverride-com.apple.MobileAsset.UAF.Photos.SpatialPhotosRelive"
    ] (_: "https://127.0.0.1:9/removemacai-blocked/");
    "com.apple.MobileSMS".messageSummarizationEnabled = false;
    "com.apple.Safari" = {
      SuppressSearchSuggestions = true;
      UniversalSearchEnabled = false;
    };
    "com.apple.Siri" = {
      StatusMenuVisible = false;
      VoiceTriggerUserEnabled = false;
    };
    "com.apple.assistant.support" = {
      "Assistant Enabled" = false;
      "Search Queries Data Sharing Status" = 2;
      "Siri Data Sharing Opt-In Status" = 2;
    };
    "com.apple.lookup.shared".LookupSuggestionsDisabled = true;
    "com.apple.spatialphotosrelive".LocallyDisabled = true;
    "group.com.apple.mail" = {
      DisableAutomaticMessageSummarization = true;
      PersonalizedSmartReplies = false;
    };
    "group.com.apple.usernoted".summarize_previews = false;
    # Preserve the app's status marker along with the restrictions it describes.
    ${identifier} = {
      ai = true;
      installed = true;
      kept = "";
      tweaks = lib.concatStringsSep "," [
        "analytics"
        "book-store"
        "game-center"
        "improve-search"
        "improve-siri"
        "iphone-mirroring"
        "lookup-suggestions"
        "music-classic"
        "personalized-ads"
        "safari-suggestions"
        "spotlight-web"
      ];
    };
  };
  uuids = {
    ".GlobalPreferences" = "11ED6143-5227-5A22-83F3-FA0E0C7F0794";
    "com.apple.MobileAsset" = "6584C3B2-85A9-5F9B-9857-A0C1D1DE2CA4";
    "com.apple.MobileSMS" = "C87077F7-EBAA-5793-B96C-91F0E4E4D710";
    "com.apple.Safari" = "89A34E07-5D73-5F6F-AE56-30CC2649D288";
    "com.apple.Siri" = "3C9AF865-A919-5348-9CCB-989D5F0CA545";
    "com.apple.assistant.support" = "FC4630BD-3AD5-5583-B936-5105A34D76FD";
    "com.apple.lookup.shared" = "D2C9628C-406C-5360-B602-1B79756500AC";
    "com.apple.spatialphotosrelive" = "5F7C55B2-2E9E-5BA6-9521-35EDEA7FCC25";
    "group.com.apple.mail" = "EF62506A-6B8E-5931-9A89-F66C67F62D72";
    "group.com.apple.usernoted" = "2D4072A1-F431-5043-B990-C1C7A2278FE1";
    ${identifier} = "307BE890-F6C6-50A0-9E82-1BA2C055079C";
  };
  profile = {
    PayloadType = "Configuration";
    PayloadVersion = 1;
    PayloadIdentifier = identifier;
    PayloadUUID = "7C031166-2E85-5BC5-9EBF-EA0E58ED34B1";
    PayloadDisplayName = "RemoveMacAI";
    PayloadDescription = "Turns off Apple Intelligence and the settings chosen in RemoveMacAI, and stops removed models downloading again. Remove this profile to undo.";
    PayloadOrganization = "RemoveMacAI";
    PayloadScope = "System";
    PayloadRemovalDisallowed = false;
    PayloadContent = [
      (
        restrictions
        // {
          PayloadType = "com.apple.applicationaccess";
          PayloadVersion = 1;
          PayloadIdentifier = "${identifier}.restrictions";
          PayloadUUID = "FC69A131-23A4-558C-8C21-343E1DDC8A69";
          PayloadDisplayName = "Restrictions";
        }
      )
    ]
    ++ lib.mapAttrsToList (domain: settings: {
      PayloadType = "com.apple.ManagedClient.preferences";
      PayloadVersion = 1;
      PayloadIdentifier = "${identifier}.preferences.${domain}";
      PayloadUUID = uuids.${domain};
      PayloadDisplayName = "Forced settings: ${domain}";
      PayloadContent.${domain}.Forced = [ { mcx_preference_settings = settings; } ];
    }) preferences;
  };
in
{
  # macOS requires interactive approval to install configuration profiles.
  # Ordinary `defaults write` settings cannot replace these managed restrictions.
  environment.etc."profiles/RemoveMacAI.mobileconfig".text = lib.generators.toPlist {
    escape = true;
  } profile;

  home-manager.users.hdjenkov = { lib, ... }: {
    home.activation.showLibrary = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run /usr/bin/chflags nohidden "$HOME/Library"
    '';
  };
}
