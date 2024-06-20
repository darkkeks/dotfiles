call plug#begin(stdpath('config') . '/plugged')

" Switches layout in normal mode to english, and back in insert mode
Plug 'vim-scripts/vim-xkbswitch'
let g:XkbSwitchEnabled = 1

" Latex support
Plug 'lervag/vimtex'
let g:tex_flavor = 'latex'
let g:vimtex_view_method = 'skim'
let g:vimtex_quickfix_mode = 0
let g:vimtex_compiler_latexmk = {'build_dir': '.build'}
let g:tex_conceal = 'abdmg'

" Snippets for latex
Plug 'SirVer/ultisnips'
let g:UltiSnipsExpandTrigger = '<tab>'
let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'

" Code completion
Plug 'Valloric/YouCompleteMe'

call plug#end()

" Remove conceal background (messed up in some schemes)
highlight Conceal ctermbg=NONE

" Enable line numbers and disable wrapping
set number
set nowrap

" Always use 4 spaces for indentation
set tabstop=4
set shiftwidth=0
set expandtab

" Cursor shape restoration on nvim enter/resume and suspend/exit
au VimEnter,VimResume * set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20
au VimLeave,VimSuspend * set guicursor=a:hor25

" Tex autocommands
augroup ft_tex
    au!
    " Enable spelling check
    au FileType tex setlocal spell
    au FileType tex set spelllang=ru,en_us
augroup END
