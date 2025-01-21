{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.dwarf-fortress;
in

{

  options.nmasur.presets.programs.dwarf-fortress.enable = lib.mkEnableOption "Dwarf Fortress";

  config = lib.mkIf cfg.enable {
    unfreePackages = [
      "dwarf-fortress"
      "phoebus-theme"
    ];
    environment.systemPackages =
      let
        dfDesktopItem = pkgs.makeDesktopItem {
          name = "dwarf-fortress";
          desktopName = "Dwarf Fortress";
          exec = "${pkgs.dwarf-fortress-packages.dwarf-fortress-full}/bin/dfhack";
          terminal = false;
        };
        dtDesktopItem = pkgs.makeDesktopItem {
          name = "dwarftherapist";
          desktopName = "Dwarf Therapist";
          exec = "${pkgs.dwarf-fortress-packages.dwarf-fortress-full}/bin/dwarftherapist";
          terminal = false;
        };
      in
      [
        pkgs.dwarf-fortress-packages.dwarf-fortress-full
        dfDesktopItem
        dtDesktopItem
      ];

  };
}
