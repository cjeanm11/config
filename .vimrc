" Basic settings
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set ai                " Auto-indent
set number            " Show line numbers
set hlsearch          " Highlight search results
set ruler             " Show cursor position
set clipboard=unnamedplus

" Cursor shape settings for different modes
let &t_SI = "\e[6 q"  " Insert mode
let &t_SR = "\e[4 q"  " Replace mode
let &t_EI = "\e[2 q"  " Normal mode

" Key mappings for screen terminals
if &term =~ '^screen'
    execute "set <xUp>=\e[1;*A"
    execute "set <xDown>=\e[1;*B"
    execute "set <xRight>=\e[1;*C"
    execute "set <xLeft>=\e[1;*D"
endif

" Clipboard and paste mappings
vnoremap <C-c> "+y
nnoremap <C-v> "+P
vnoremap <expr> <C-v> '"+p'
nnoremap <S-Insert> "+P
inoremap <S-Insert> <C-r>+
inoremap <C-v> <C-r>+
cnoremap <C-v> <C-r>+
vnoremap <C-v> c<ESC>"+p
inoremap <S-Insert> <C-r>+
cnoremap <S-Insert> <C-r>+

set clipboard+=unnamed
set paste
