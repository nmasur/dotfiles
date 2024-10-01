{
  config,
  pkgs,
  lib,
  ...
}:
{

  options.gaming.dwarf-fortress.enable = lib.mkEnableOption "Dwarf Fortress free edition.";

  config = lib.mkIf config.gaming.dwarf-fortress.enable {
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
