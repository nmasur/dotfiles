{
  pkgs,
  dsl,
  lib,
  ...
}:
{
  plugins = [
    pkgs.vimPlugins.vim-surround # Keybinds for surround characters
    pkgs.vimPlugins.vim-eunuch # File manipulation commands
    pkgs.vimPlugins.vim-fugitive # Git commands
    pkgs.vimPlugins.vim-repeat # Better repeat using .
    pkgs.vimPlugins.vim-abolish # Keep capitalization in substitute (Subvert)
    pkgs.vimPlugins.markview-nvim # Markdown preview
    pkgs.vimPlugins.nvim-colorizer-lua # Hex color previews
    pkgs.vimPlugins.which-key-nvim # Keybind helper
  ];

  # Initialize some plugins
  setup.colorizer = {
    user_default_options = {
      names = false;
    };
  };
  setup.markview = { };
  setup.which-key = { };

  vim.o = {
    termguicolors = true; # Set to truecolor
    hidden = true; # Don't unload buffers when leaving them
    list = true; # Reveal whitespace with dashes
    expandtab = true; # Tabs into spaces
    shiftwidth = 4; # Amount to shift with > key
    softtabstop = 4; # Amount to shift with <TAB> key
    ignorecase = true; # Ignore case when searching
    smartcase = true; # Check case when using capitals in search
    infercase = true; # Don't match cases when completing suggestions
    incsearch = true; # Search while typing
    visualbell = true; # No sounds
    scrolljump = 1; # Number of lines to scroll
    scrolloff = 3; # Margin of lines to see while scrolling
    splitright = true; # Vertical splits on the right side
    splitbelow = true; # Horizontal splits on the bottom side
    clipboard = "unnamedplus"; # Uses system clipboard for yanking
    updatetime = 300; # Faster diagnostics
    mouse = "nv"; # Mouse interaction / scrolling
    inccommand = "split"; # Live preview search and replace
  };

  vim.wo = {
    number = true; # Show line numbers
    relativenumber = true; # Relative numbers instead of absolute
  };

  # For which-key-nvim
  vim.o.timeout = true;
  vim.o.timeoutlen = 300;

  # Better backup, swap and undo storage
  vim.o.backup = true; # Easier to recover and more secure
  vim.opt.undofile = true; # Keeps undos after quit
  vim.opt.swapfile = false; # Instead of swaps, create backups
  vim.o.backupdir = dsl.rawLua ''vim.fn.expand("~/.local/state/nvim/backup//")'';
  vim.o.undodir = dsl.rawLua ''vim.fn.expand("~/.local/state/nvim/undo//")'';

  # Required for nvim-cmp completion
  vim.opt.completeopt = [
    "menu"
    "menuone"
    "noselect"
  ];

  lua = lib.mkBefore ''
    vim.loader.enable()
    ${builtins.readFile ../lua/keybinds.lua};
    ${builtins.readFile ../lua/settings.lua};
  '';

  vimscript = ''
    " Remember last position when reopening file
    au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

    " Flash highlight when yanking
    au TextYankPost * silent! lua vim.highlight.on_yank { timeout = 250 }
  '';
}
