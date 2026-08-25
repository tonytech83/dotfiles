syntax on
" Enable syntax highlighting

set fileformat=unix
" Use Unix line endings (LF) for files, not Windows (CRLF) or old Mac (CR)

set encoding=UTF-8
" Set internal character encoding to UTF-8

au BufNewFile,BufRead *.py
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
" Autocommand: when opening/creating a .py file, override indent settings
" to use 4 spaces (Python convention) instead of the global 2-space setting below.
" tabstop=4      -> a literal tab character displays as 4 columns wide
" softtabstop=4  -> pressing Tab/Backspace acts like 4 spaces
" shiftwidth=4   -> autoindent / >> << shift by 4 spaces
" (note: trailing `|` after the last line is harmless but unnecessary since
"  it's the last command in the chain)

set tabstop=2
" Global default: a tab character displays as 2 columns wide

set softtabstop=2
" Global default: Tab/Backspace insert/remove 2 spaces at a time

set shiftwidth=2
" Global default: indentation commands (>>, <<, autoindent) shift by 2 spaces

set autoindent
" Copy the indentation from the current line when starting a new line

set smartindent
" Add some C-like smart auto-indenting (e.g. after `{`), language-agnostic heuristic

set smarttab
" Tab/Backspace at the start of a line respect shiftwidth/tabstop settings intelligently

set expandtab
" Convert typed tabs into spaces (uses tabstop/softtabstop width)

set nowrap
" Don't visually wrap long lines onto the next screen line; let them extend off-screen

set nolist
" Show "invisible" characters (tabs, trailing spaces, etc.) using listchars below

set listchars=eol:.,tab:>-,trail:~,extends:>,precedes:<
" Define how invisible characters are displayed:
"   eol:.      -> end of line shown as .
"   tab:>-     -> tabs shown as >---- 
"   trail:~    -> trailing whitespace shown as ~
"   extends:>  -> line continues beyond right edge of screen (nowrap) shown as >
"   precedes:< -> line extends beyond left edge (when scrolled) shown as 

set cursorline
" Highlight the screen line the cursor is currently on

set number
" Show absolute line number on the current line

"set relativenumber
" Show relative line numbers on all other lines (combined with `number`,
" this gives "hybrid" line numbers — great for motions like 5j / 3dd)

set scrolloff=8
" Keep at least 8 lines visible above/below the cursor when scrolling

set signcolumn=yes
" Always show the sign column (used by linters/git plugins for markers),
" preventing text from shifting left/right when signs appear/disappear

set showcmd
" Show partially-typed commands in the bottom right (e.g. while typing "2dd")

set showmode
" Show -- INSERT --/-- VISUAL -- etc. in the command line
" (usually because a statusline plugin already shows the mode)

set conceallevel=1
" Enable "conceal" — hide/replace certain syntax (e.g. markdown `**bold**`
" markers, or LaTeX symbols) with a nicer visual representation, if the
" filetype's syntax defines conceal rules

set shortmess+=c
" Suppress completion-menu messages like "match 1 of 4" or "Pattern not found"
" (reduces noise, especially with autocomplete plugins)

set formatoptions-=cro
" Disable auto-continuation of comments:
"   c -> auto-wrap comments using textwidth
"   r -> auto-insert comment leader after <Enter> in insert mode
"   o -> auto-insert comment leader after 'o'/'O' in normal mode
" Removing these stops Vim from automatically adding "// " or "# " etc.
" on new lines when you're writing/editing comments

set noerrorbells visualbell t_vb=
" Disable the audible error bell (noerrorbells), enable "visual bell" instead,
" but then set the visual bell terminal code to empty (t_vb=), effectively
" silencing/disabling both audible and visual bells entirely

set noswapfile
" Don't create .swp swap files

set nobackup
" Don't create backup~ files when overwriting a file

set undodir=~/.vim/undodir
" Directory where persistent undo history files are stored
" (must exist beforehand, or undofile below will fail silently for new files)

set undofile
" Save undo history to disk per-file, so you can undo changes even after
" closing and reopening the file

set clipboard=unnamed
" Use the system clipboard as the default register (yank/paste integrates
" with OS copy-paste); "unnamed" maps to the "* register (primary/select
" on Linux, or system clipboard on macOS/Windows)

set ignorecase
" Make search patterns case-insensitive by default

set smartcase
" Override ignorecase: if the search pattern contains an uppercase letter,
" search becomes case-sensitive (only takes effect when ignorecase is also set)

set incsearch
" Show search matches incrementally as you type the pattern

set hlsearch
" Highlight all matches of the current search pattern

nnoremap <CR> :noh<CR><CR>:<backspace>
" Remap Enter in Normal mode to clear search highlighting (:noh) and then
" re-execute Enter's normal behavior. Breakdown:
"   :noh<CR>      -> run ":nohlsearch" (turn off highlight until next search)
"   <CR>          -> literal Enter, executing the :noh command
"   :<backspace>  -> opens command-line then immediately backspaces out of it
"                    (a no-op trick, likely leftover/defensive coding to avoid
"                    disrupting Enter's normal cursor-move behavior in some contexts)

"-- COLOR & THEME CONFIG
" Just a comment header/divider (starts with " which is Vim's comment character)

set termguicolors
" Enable 24-bit RGB true color in the terminal (needed for accurate theme colors,
" requires a terminal emulator that supports it)

set background=dark
" Tell Vim/the colorscheme to use its dark variant
" (note: setting this AFTER `colorscheme` can sometimes require the
" colorscheme to reload; some configs set background before colorscheme instead)

hi Normal guibg=NONE ctermbg=NONE
" Override the "Normal" highlight group to have no background color,
" making the editor background transparent (shows your terminal's own
" background, e.g. for terminal transparency effects) in both GUI (guibg)
" and terminal (ctermbg) modes

let g:terminal_ansi_colors = [
    \ '#282828', '#cc241d', '#98971a', '#d79921', '#458588', '#b16286', '#689d6a', '#a89984',
    \ '#928374', '#fb4934', '#b8bb26', '#fabd2f', '#83a598', '#d3869b', '#8ec07c', '#ebdbb2',
\]
" Define the 16-color ANSI palette (gruvbox colors) used by Vim's built-in
" :terminal emulator, so terminal buffers opened inside Vim match the
" gruvbox theme. Order is the standard ANSI 0-15: black, red, green, yellow,
" blue, magenta, cyan, white, then their "bright" counterparts
