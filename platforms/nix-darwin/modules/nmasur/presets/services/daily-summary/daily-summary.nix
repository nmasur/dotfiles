{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.nmasur.settings) username;
  cfg = config.nmasur.presets.services.daily-summary;

  # Remove process urls in favor of using extention
  # process_urls = pkgs.writers.writePython3Bin "process-urls" {
  #   libraries = [
  #     pkgs.python3Packages.requests
  #     pkgs.python3Packages.beautifulsoup4
  #   ];
  # } (builtins.readFile ./process-urls.py);
  # prompt = "Based on my browser usage for today from the markdown file located in /Users/${username}/Downloads/Sidebery/todays_urls.md, create or update a daily summary markdown file in the generated notes directory located in /Users/${username}/dev/personal/notes/generated/ with the filename format 'YYYY-MM-DD Daily Summary.md'. The resulting markdown file should use /Users/${username}/dev/personal/notes/templates/generated-summary.md as a format template, and it should summarize where I have spent my time today and highlight any notable links that I have visited. Please create markdown links to other relevant notes in /Users/${username}/dev/personal/notes/. If there is an existing markdown file for today, update it to include the newest information.";
  prompt = "Based on my browser usage for today from the JSON file located in /Users/${username}/Downloads/firefox-history/history-YYYY-MM-DD.json, create or update a daily summary markdown file in the generated notes directory located in /Users/${username}/dev/personal/notes/generated/ with the filename format 'YYYY-MM-DD Daily Summary.md'. If the JSON file for today doesn't exist, exit. The resulting markdown file should use /Users/${username}/dev/personal/notes/templates/generated-summary.md as a format template, and it should summarize where I have spent my time today and highlight any notable pages that I have visited, using the titles of each URL in the JSON file for markdown links. Please create markdown links to other relevant notes in /Users/${username}/dev/personal/notes/ and explain why they are being referenced. If there is an existing markdown file for today, update it to include the newest information.";
in

{

  options.nmasur.presets.services.daily-summary.enable = lib.mkEnableOption "Daily work summary";

  config = lib.mkIf cfg.enable {
    launchd.user.agents.daily-summary = {
      # This replaces program and args entirely
      # script = ''
      #   ${process_urls}/bin/process-urls /Users/${username}/Downloads/Sidebery/
      #   GEMINI_API_KEY=$(cat /Users/${username}/.config/gemini/.gemini_api_key) ${pkgs.gemini-cli}/bin/gemini --allowed-tools all --yolo --include-directories /Users/${username}/Downloads/Sidebery/ --include-directories /Users/${username}/dev/personal/notes/ "${prompt}"
      # '';
      script = ''
        GEMINI_API_KEY=$(cat /Users/${username}/.config/gemini/.gemini_api_key) ${pkgs.gemini-cli}/bin/gemini --allowed-tools all --yolo --include-directories "/Users/${username}/Downloads/firefox-history/,/Users/${username}/dev/personal/notes/" "${prompt} | tee -a /Users/${username}/dev/personal/gemini-archive/daily-summary-logs/$(date +"%Y-%m-%d").log"
      '';

      path = [
        pkgs.bash
        pkgs.coreutils
      ];

      serviceConfig = {
        Label = "com.example.daily-summary";
        # Runs the script through /bin/sh automatically
        # RunAtLoad = true;
        StartCalendarInterval = [
          {
            Hour = 4;
            Minute = 45;
          }
          {
            Hour = 6;
            Minute = 0;
          }
          {
            Hour = 9;
            Minute = 0;
          }
          {
            Hour = 11;
            Minute = 0;
          }
        ];
      };

    };
  };

}
