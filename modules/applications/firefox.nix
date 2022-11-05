{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.gui.enable {

    unfreePackages = [ "onepassword-password-manager" "okta-browser-plugin" ];

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
            "browser.quitShortcut.disabled" = true;
            "browser.theme.dark-private-windows" = true;
            "browser.toolbars.bookmarks.visibility" = "newtab";
            "browser.startup.page" = 3; # Restore previous session
            "browser.newtabpage.enabled" = false; # Make new tabs blank
            "general.autoScroll" = true; # Drag middle-mouse to scroll
            "services.sync.prefs.sync.general.autoScroll" =
              false; # Prevent disabling autoscroll
            "extensions.pocket.enabled" = false;
            "toolkit.legacyUserProfileCustomizations.stylesheets" =
              true; # Allow userChrome.css
            "layout.css.color-mix.enabled" = true;
            "ui.systemUsesDarkTheme" =
              if config.theme.dark == true then 1 else 0;
          };
          userChrome = ''
            :root {
              --focus-outline-color: ${config.theme.colors.base04} !important;
              --toolbar-color: ${config.theme.colors.base07} !important;
              --tab-min-height: 30px !important;
            }
            /* Background of tab bar */
            .toolbar-items {
              background-color: ${config.theme.colors.base00} !important;
            }
            /* Tabs themselves */
            .tabbrowser-tab .tab-stack {
              border-radius: 5px 5px 0 0;
              overflow: hidden;
              background-color: ${config.theme.colors.base00};
              color: ${config.theme.colors.base06} !important;
            }
            .tab-content {
              border-bottom: 2px solid color-mix(in srgb, var(--identity-tab-color) 40%, transparent);
              border-radius: 5px 5px 0 0;
              background-color: ${config.theme.colors.base00};
              color: ${config.theme.colors.base06} !important;
            }
            .tab-content[selected=true] {
              border-bottom: 2px solid color-mix(in srgb, var(--identity-tab-color) 25%, transparent);
              background-color: ${config.theme.colors.base01} !important;
              color: ${config.theme.colors.base07} !important;
            }
            /* Below tab bar */
            #nav-bar {
              background: ${config.theme.colors.base01} !important;
            }
            /* URL bar in nav bar */
            #urlbar[focused=true] {
              color: ${config.theme.colors.base07} !important;
              background: ${config.theme.colors.base02} !important;
              caret-color: ${config.theme.colors.base05} !important;
            }
            #urlbar:not([focused=true]) {
              color: ${config.theme.colors.base04} !important;
              background: ${config.theme.colors.base02} !important;
            }
            #urlbar ::-moz-selection {
              color: ${config.theme.colors.base07} !important;
              background: ${config.theme.colors.base02} !important;
            }
            #urlbar-input-container {
              border: 1px solid ${config.theme.colors.base01} !important;
            }
            #urlbar-background {
              background: ${config.theme.colors.base01} !important;
            }
            /* Text in URL bar */
            #urlbar-input, #urlbar-scheme, .searchbar-textbox {
              color: ${config.theme.colors.base07} !important;
            }
          '';
          userContent = ''
            @-moz-document url-prefix(about:blank) {
              * {
                background-color:${config.theme.colors.base01} !important;
              }
            }
          '';

          extraConfig = "";
        };

      };
    };

  };

}
