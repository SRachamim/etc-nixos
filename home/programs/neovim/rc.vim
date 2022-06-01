" Vim configuration file

" Set basic settings {{{
set laststatus  =2         " Always show statusline.
set showmode               " Show current mode in command-line.
set hlsearch               " Keep matches highlighted.
set lazyredraw             " Only redraw when necessary.
set splitbelow             " Open new windows below the current window.
set splitright             " Open new windows right of the current window.
set wrapscan               " Searches wrap around end-of-file.
set report      =0         " Always report changed lines.
set synmaxcol   =200       " Only highlight the first 200 columns.
set encoding=utf-8         " use utf-8 encoding
set autoread               " automatically reload buffers
set number                 " show line numbers
set termguicolors          " suuport TrueColors
set noswapfile
set breakindent
set cursorline

" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

" Set grep programm to use ripgrep{{{2
if executable("rg")
    set grepprg=rg\ --vimgrep\ --no-heading
    set grepformat=%f:%l:%c:%m,%f:%l:%m
endif
" }}}2
" }}}

" Set mappings {{{

" Map <Leader> to `\`
let mapleader = "\<Space>"

" Map <Ctrl-l> to also: {{{2
" - Stop the highlighting for the 'hlsearch' option.
" - Update the diff highlighting and folds.
" - The file will be parsed from the start.
" - Clear and redraw the screen.
nnoremap <c-l> :nohlsearch<cr>:diffupdate<cr>:syntax sync fromstart<cr><c-l>
" }}}2
" }}}

if !has('nvim')
  set viminfo+=n~/vim/viminfo
else
  " Do nothing here to use the neovim default
  " or do soemething like:
  " set viminfo+=n~/.shada
endif

" Set region to English
set spelllang=en_gb
