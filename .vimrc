syntax enable
filetype plugin indent on

set viminfofile=~/.local/state/vim/viminfo
let g:netrw_dirhistmax = 0
set scrolloff=8
set mouse=a

if exists('$SSH_TTY') || exists('$SSH_CONNECTION')
    let g:osc52_force_avail = 1
    packadd osc52
    set clipmethod^=osc52
    set clipboard^=unnamedplus
elseif has('unnamedplus')
    set clipboard^=unnamedplus
elseif has('clipboard')
    set clipboard^=unnamed
endif

set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=-1
set ignorecase
set smartcase
set incsearch
set hlsearch
