{ pkgs, lib, config, ... }: {

  options.colors = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    description = "Attrset of base16 colorscheme key value pairs.";
  };

  config = {
    plugins = [ pkgs.vimPlugins.nvim-base16 ];
    setup.base16-colorscheme = config.colors;
  };

}
