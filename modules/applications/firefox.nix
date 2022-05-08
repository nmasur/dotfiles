{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.gui.enable {
    home-manager.users.${config.user} = {

      programs.firefox = {
        enable = true;
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          vimium
          multi-account-containers
          facebook-container
          temporary-containers
          onepassword-password-manager
          okta-browser-plugin
          sponsorblock
          reddit-enhancement-suite
          bypass-paywalls-clean
          markdownload
          darkreader
          snowflake
          don-t-fuck-with-paste
          i-dont-care-about-cookies
        ];
        profiles.Profile0 = {
          id = 0;
          name = "default";
          isDefault = true;
          settings = {
            "browser.aboutConfig.showWarning" = false;
            "browser.warnOnQuit" = false;
            "browser.theme.dark-private-windows" = true;
            "browser.toolbars.bookmarks.visibility" = "newtab";
            "browser.startup.page" = 3; # Restore previous session
            "browser.newtabpage.enabled" = false; # Make new tabs blank
            "general.autoScroll" = true; # Drag middle-mouse to scroll
            "extensions.pocket.enabled" = false;
            "toolkit.legacyUserProfileCustomizations.stylesheets" =
              true; # Allow userChrome.css
          };
          userChrome = ''
            :root {
              --focus-outline-color: ${config.gui.colorscheme.base04} !important;
              --toolbar-color: ${config.gui.colorscheme.base07} !important;
            }
            /* Background of tab bar */
            .toolbar-items {
              background-color: ${config.gui.colorscheme.base00} !important;
            }
            /* Tabs themselves */
            .tabbrowser-tab .tab-stack {
              border-radius: 5px 5px 0 0;
              overflow: hidden;
            }
            .tab-content {
              background-color: ${config.gui.colorscheme.base00} !important;
              color: ${config.gui.colorscheme.base06} !important;
            }
            .tab-content[selected=true] {
              background-color: ${config.gui.colorscheme.base01} !important;
              color: ${config.gui.colorscheme.base07} !important;
            }
            /* Below tab bar */
            #nav-bar {
              background: ${config.gui.colorscheme.base01} !important;
            }
            /* URL bar in nav bar */
            #urlbar[focused=true] {
              color: ${config.gui.colorscheme.base07} !important;
              background: ${config.gui.colorscheme.base02} !important;
              caret-color: ${config.gui.colorscheme.base05} !important;
            }
            #urlbar:not([focused=true]) {
              color: ${config.gui.colorscheme.base04} !important;
              background: ${config.gui.colorscheme.base02} !important;
            }
            #urlbar ::-moz-selection {
              color: ${config.gui.colorscheme.base07} !important;
              background: ${config.gui.colorscheme.base02} !important;
            }
            #urlbar-input-container {
              border: 1px solid ${config.gui.colorscheme.base01} !important;
            }
            #urlbar-background {
              background: ${config.gui.colorscheme.base01} !important;
            }
            /* Text in URL bar */
            #urlbar-input, #urlbar-scheme, .searchbar-textbox {
              color: ${config.gui.colorscheme.base07} !important;
            }
          '';
          userContent = ''
            @-moz-document url-prefix(about:blank) {
              * {
                background-color:${config.gui.colorscheme.base01} !important;
              }
            }
          '';

          extraConfig = "";
        };

      };

      gtk = {
        enable = true;
        theme =
          config.services.xserver.displayManager.lightdm.greeters.gtk.theme;
      };
    };

    # Required for setting GTK theme (for preferred-color-scheme in browser)
    services.dbus.packages = [ pkgs.dconf ];
    programs.dconf.enable = true;

  };

}
