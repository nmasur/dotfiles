{ pkgs, dsl, ... }: {

  plugins = [ pkgs.vimPlugins.toggleterm-nvim ];

  use.toggleterm.setup = dsl.callWith {
    open_mapping = dsl.rawLua "[[<c-\\>]]";
    hide_numbers = true;
    direction = "float";
  };

  lua = builtins.readFile ./toggleterm.lua;

}
