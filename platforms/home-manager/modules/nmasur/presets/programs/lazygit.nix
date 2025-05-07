{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.lazygit;
in

{
  options.nmasur.presets.programs.lazygit.enable = lib.mkEnableOption "Lazygit git TUI";

  config = lib.mkIf cfg.enable {
    programs.lazygit = {
      enable = true;
      settings = {
        git.paging = {
          # useConfig = true;
          pager = "${pkgs.git}/share/git/contrib/diff-highlight/diff-highlight";
        };
        os = {
          edit = "${config.home.sessionVariables.EDITOR} {{filename}}";
          editAtLine = "${config.home.sessionVariables.EDITOR} {{filename}}:{{line}}";
          editAtLineAndWait = "${config.home.sessionVariables.EDITOR} {{filename}}:{{line}}";
          openDirInEditor = "${config.home.sessionVariables.EDITOR}";
          open = "${config.home.sessionVariables.EDITOR} {{filename}}";
        };
        customCommands = [
          {
            key = "N";
            context = "files";
            command = "git add -N {{.SelectedFile.Name}}";
          }
          {
            key = "<a-enter>";
            context = "global";
            command =
              let
                openGitUrl = pkgs.writeShellScriptBin "open-git-url" ''
                  # Try to get the remote URL using two common methods; suppress stderr for individual commands.
                  # "git remote get-url origin" is generally preferred.
                  # "git config --get remote.origin.url" is a fallback.
                  URL=$(git remote get-url origin 2>/dev/null || git config --get remote.origin.url 2>/dev/null);

                  # Check if a URL was actually found.
                  if [ -z "$URL" ]; then
                    # Send error message to stderr so it might appear in lazygit logs or notifications.
                    echo "Lazygit: Could not determine remote URL for 'origin'." >&2;
                    # Exit with an error code.
                    exit 1;
                  fi;

                  # Check if the URL is a GitHub SSH URL and convert it to HTTPS.
                  # This uses echo and grep to check for "@github.com" and then sed for transformation.
                  if echo "$URL" | grep -q "@github.com:"; then
                    # Transform git@github.com:user/repo.git to https://github.com/user/repo
                    # The first sed handles the main transformation.
                    # The second sed removes a trailing .git if present, for a cleaner URL.
                    URL=$(echo "$URL" | sed "s|git@github.com:|https://github.com/|" | sed "s|\.git$||");
                    # Optional: Log the transformation for debugging.
                    # echo "Lazygit: Transformed GitHub SSH URL to '$URL'" >&2;
                  fi;

                  # Determine the operating system.
                  OS="$(uname -s)";

                  # Optional: Echo for debugging. This might appear in lazygit logs or as a brief message.
                  # Remove " >&2" if you want to see it as a potential success message in lazygit UI (if it shows stdout).
                  # echo "Lazygit: Opening URL '$URL' on '$OS'" >&2;

                  # Execute the appropriate command to open the URL based on the OS.
                  case "$OS" in
                    Darwin*) # macOS
                      open "$URL";;
                    Linux*)  # Linux
                      xdg-open "$URL";;
                    *)       # Unsupported OS
                      echo "Lazygit: Unsupported OS ('$OS'). Could not open URL." >&2;
                      exit 1;;
                  esac
                '';
              in
              lib.getExe openGitUrl;
          }
        ];
      };
    };

    programs.fish.shellAbbrs = {
      lg = "lazygit";
    };

  };
}
