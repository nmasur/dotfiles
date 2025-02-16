{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.profiles.linux-gui;
in

{

  options.nmasur.profiles.linux-gui.enable = lib.mkEnableOption "Linux GUI home";

  config = lib.mkIf cfg.enable {

    nmasur.gtk.enable = lib.mkDefault true;
    nmasur.presets = {
      programs = {
        _1password.enable = lib.mkDefault true;
        aerc.enable = lib.mkDefault true;
        discord.enable = lib.mkDefault true;
        dotfiles.enable = lib.mkDefault true;
        firefox.enable = lib.mkDefault true;
        mpv.enable = lib.mkDefault true;
        nautilus.enable = lib.mkDefault true;
        nsxiv.enable = lib.mkDefault true;
        obsidian.enable = lib.mkDefault true;
        xclip.enable = lib.mkDefault true;
        wezterm.enable = lib.mkDefault true;
        zathura.enable = lib.mkDefault true;
      };
      services = {
        dunst.enable = lib.mkDefault false; # Off by default
        i3.enable = lib.mkDefault true;
        kanata.enable = lib.mkDefault true;
        keybase.enable = lib.mkDefault true;
        mbsync.enable = lib.mkDefault true;
        picom.enable = lib.mkDefault true;
        polybar.enable = lib.mkDefault true;
        volnoti.enable = lib.mkDefault true;
      };
    };

  };
}
