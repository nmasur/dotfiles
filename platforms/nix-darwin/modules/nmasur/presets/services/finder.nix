{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.services.finder;
in

{

  options.nmasur.presets.services.finder.enable = lib.mkEnableOption "macOS Finder options";

  config = lib.mkIf cfg.enable {
    system.defaults = {

      finder = {

        # Default Finder window set to column view
        FXPreferredViewStyle = "clmv";

        # Finder search in current folder by default
        FXDefaultSearchScope = "SCcf";

        # Disable warning when changing file extension
        FXEnableExtensionChangeWarning = false;

        # Allow quitting of Finder application
        QuitMenuItem = true;
      };

      NSGlobalDomain = {

        # Save to local disk by default, not iCloud
        NSDocumentSaveNewDocumentsToCloud = false;

      };

      CustomUserPreferences = {

        "com.apple.finder" = {
          # Disable the warning before emptying the Trash
          WarnOnEmptyTrash = false;

          # Finder search in current folder by default
          FXDefaultSearchScope = "SCcf";

          # Default Finder window set to column view
          FXPreferredViewStyle = "clmv";
        };
        # Avoid creating .DS_Store files on network or USB volumes
        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
      };

    };

    # User-level settings
    system.activationScripts.postUserActivation.text = ''
      echo "Show the ~/Library folder"
      chflags nohidden ~/Library
    '';

  };
}
