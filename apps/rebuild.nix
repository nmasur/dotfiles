{ pkgs, ... }: {

  type = "app";

  program = builtins.toString (pkgs.writeShellScript "rebuild" ''
    echo ${pkgs.system}
    SYSTEM=${if pkgs.stdenv.isDarwin then "darwin" else "linux"}
    if [ "$SYSTEM" == "darwin" ]; then
        darwin-rebuild switch --flake github:nmasur/dotfiles#lookingglass
    else
        nixos-rebuild switch --flake github:nmasur/dotfiles
    fi
  '');

}
