{ pkgs, ... }: {

  # Requires Xorg to work
  imports = [ ./xorg.nix ];

  services.xserver.windowManager = { i3 = { enable = true; }; };

  environment.systemPackages = with pkgs; [
    dmenu # Launcher
    feh # Wallpaper
    playerctl # Media control
    polybarFull # Polybar + PulseAudio
  ];

}
