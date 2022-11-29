{ pkgs, dsl, lib, ... }: {
  plugins = [
    pkgs.vimPlugins.vim-surround # Keybinds for surround characters
    pkgs.vimPlugins.vim-eunuch # File manipulation commands
    pkgs.vimPlugins.vim-fugitive # Git commands
    pkgs.vimPlugins.vim-repeat # Better repeat using .
    pkgs.vimPlugins.comment-nvim # Smart comment commands
    pkgs.vimPlugins.impatient-nvim # Faster load times
    pkgs.vimPlugins.glow-nvim # Markdown preview popup
    pkgs.vimPlugins.nvim-colorizer-lua # Hex color previews
  ];

  setup.Comment = { };
  setup.colorizer = { };

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

  # Better backup, swap and undo storage
  vim.o.backup = true; # Easier to recover and more secure
  vim.bo.swapfile = false; # Instead of swaps, create backups
  vim.bo.undofile = true; # Keeps undos after quit
  vim.o.backupdir = dsl.rawLua ''vim.fn.stdpath("cache") .. "/backup"'';

  # Required for nvim-cmp completion
  vim.opt.completeopt = [ "menu" "menuone" "noselect" ];

  lua = lib.mkBefore ''
    require("impatient")
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
