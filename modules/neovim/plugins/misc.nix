{ pkgs, lib, ... }: {
  plugins = [
    pkgs.vimPlugins.vim-surround
    pkgs.vimPlugins.vim-eunuch
    pkgs.vimPlugins.vim-vinegar
    pkgs.vimPlugins.vim-fugitive
    pkgs.vimPlugins.vim-repeat
    pkgs.vimPlugins.comment-nvim
    pkgs.vimPlugins.impatient-nvim
  ];
  setup.Comment = { };

  vim.o.termguicolors = true; # Set to truecolor
  vim.o.hidden = true; # Don't unload buffers when leaving them
  vim.wo.number = true; # Show line numbers
  vim.wo.relativenumber = true; # Relative numbers instead of absolute
  vim.o.list = true; # Reveal whitespace with dashes
  vim.o.expandtab = true; # Tabs into spaces
  vim.o.shiftwidth = 4; # Amount to shift with > key
  vim.o.softtabstop = 4; # Amount to shift with <TAB> key
  vim.o.ignorecase = true; # Ignore case when searching
  vim.o.smartcase = true; # Check case when using capitals in search
  vim.o.infercase = true; # Don't match cases when completing suggestions
  vim.o.incsearch = true; # Search while typing
  vim.o.visualbell = true; # No sounds
  vim.o.scrolljump = 1; # Number of lines to scroll
  vim.o.scrolloff = 3; # Margin of lines to see while scrolling
  vim.o.splitright = true; # Vertical splits on the right side
  vim.o.splitbelow = true; # Horizontal splits on the bottom side
  vim.o.pastetoggle = "<F3>"; # Use F3 to enter raw paste mode
  vim.o.clipboard = "unnamedplus"; # Uses system clipboard for yanking
  vim.o.updatetime = 300; # Faster diagnostics
  vim.o.mouse = "nv"; # Mouse interaction / scrolling
  vim.o.inccommand = "split"; # Live preview search and replace

  # Required for nvim-cmp completion
  vim.opt.completeopt = [ "menu" "menuone" "noselect" ];

  lua = lib.mkBefore ''
    require("impatient")
    ${builtins.readFile ../lua/keybinds.lua};
    ${builtins.readFile ../lua/settings.lua};
  '';
}
