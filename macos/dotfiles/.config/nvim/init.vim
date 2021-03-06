call plug#begin(stdpath('config') . '/plugged')

Plug 'vim-scripts/vim-xkbswitch'
let g:XkbSwitchEnabled = 1

Plug 'lervag/vimtex'
let g:tex_flavor = 'latex'
let g:vimtex_view_method = 'skim'
let g:vimtex_quickfix_mode = 0
let g:vimtex_compiler_latexmk = {'build_dir': '.build'}
let g:tex_conceal = 'abdmg'

Plug 'SirVer/ultisnips'
let g:UltiSnipsExpandTrigger = '<tab>'
let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'

Plug 'w0ng/vim-hybrid'
let g:hybrid_custom_term_colors=1
set background=dark

Plug 'ThePrimeagen/vim-be-good'

call plug#end()

colorscheme hybrid

" Remove conceal background (messed up in some schemes)
highlight Conceal ctermbg=NONE

" Line numbers and wrap
set number
set nowrap

" Always use 4 spaces
set tabstop=4
set shiftwidth=0
set expandtab

" Cursor shape restoration on nvim enter/resume and suspend/exit
au VimEnter,VimResume * set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20
au VimLeave,VimSuspend * set guicursor=a:hor25

" Tex autocommands
augroup ft_tex
    au!
    au FileType tex setlocal spell
    au FileType tex set spelllang=ru,en_us
augroup END

" Disable Arrow keys in Normal mode
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>

" Disable Arrow keys in Insert mode
imap <up> <nop>
imap <down> <nop>
imap <left> <nop>
imap <right> <nop>
