{ pkgs, dsl, lib, ... }: {
  plugins = [
    pkgs.vimPlugins.vim-surround # Keybinds for surround characters
    pkgs.vimPlugins.vim-eunuch # File manipulation commands
    pkgs.vimPlugins.vim-fugitive # Git commands
    pkgs.vimPlugins.vim-repeat # Better repeat using .
    pkgs.vimPlugins.comment-nvim # Smart comment commands
    pkgs.vimPlugins.glow-nvim # Markdown preview popup
    pkgs.vimPlugins.nvim-colorizer-lua # Hex color previews
  ];

  setup.Comment = { };
  setup.colorizer = { };

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
    pastetoggle = "<F3>"; # Use F3 to enter raw paste mode
    clipboard = "unnamedplus"; # Uses system clipboard for yanking
    updatetime = 300; # Faster diagnostics
    mouse = "nv"; # Mouse interaction / scrolling
    inccommand = "split"; # Live preview search and replace
  };

  vim.wo = {
    number = true; # Show line numbers
    relativenumber = true; # Relative numbers instead of absolute
  };

  # Better backup, swap and undo storage
  vim.o.backup = true; # Easier to recover and more secure
  vim.bo.swapfile = false; # Instead of swaps, create backups
  vim.bo.undofile = true; # Keeps undos after quit
  vim.o.backupdir = dsl.rawLua ''vim.fn.stdpath("cache") .. "/backup"'';

  # Required for nvim-cmp completion
  vim.opt.completeopt = [ "menu" "menuone" "noselect" ];

  lua = lib.mkBefore ''
    vim.loader.enable()
    ${builtins.readFile ../lua/keybinds.lua};
    ${builtins.readFile ../lua/settings.lua};
  '';

  vimscript = ''
    " Remember last position when reopening file
    au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

    " LaTeX options
    au FileType tex inoremap ;bf \textbf{}<Esc>i
    au BufWritePost *.tex silent! execute "!pdflatex -output-directory=%:p:h % >/dev/null 2>&1" | redraw!

    " Flash highlight when yanking
    au TextYankPost * silent! lua vim.highlight.on_yank { timeout = 250 }
  '';
}
