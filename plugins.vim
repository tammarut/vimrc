scriptencoding utf-8

" =============================================================================
" Interface
" =============================================================================

" Signs and highlighting for errors, etc.
let s:error_sign = '✘'
let s:error_sign_hl = 'DiagnosticErrorSign'
let s:error_hl = 'DiagnosticError'
let s:error_text_hl = 'DiagnosticErrorText'
let s:warning_sign = '♦'
let s:warning_sign_hl = 'DiagnosticWarningSign'
let s:warning_hl = 'DiagnosticWarning'
let s:warning_text_hl = 'DiagnosticWarningText'
let s:info_sign = '→'
let s:info_sign_hl = 'DiagnosticInfoSign'
let s:info_hl = 'DiagnosticInfo'
let s:info_text_hl = 'DiagnosticInfoText'
let s:hint_sign = '…'
let s:hint_sign_hl = s:info_sign_hl
let s:hint_hl = s:info_sign
let s:hint_text_hl = s:info_text_hl

" Syntax checking on save
Plug 'neomake/neomake'
let g:neomake_open_list = 2
let g:neomake_verbose = 1
let g:neomake_rust_enabled_makers=[]
let g:neomake_java_enabled_makers=['checkstyle']
let g:neomake_python_enabled_makers=['python', 'pylint']
let g:neomake_typescript_enabled_makers=['tslint']
let g:neomake_error_sign = {
      \ 'text': s:error_sign,
      \ 'texthl': s:error_sign_hl,
      \ }
let g:neomake_warning_sign = {
      \ 'text': s:warning_sign,
      \ 'texthl': s:warning_sign_hl,
      \ }
let g:neomake_info_sign = {
      \ 'text': s:info_sign,
      \ 'texthl': s:info_sign_hl,
      \ }
let g:neomake_message_sign = {
      \ 'text': s:hint_sign,
      \ 'texthl': s:hint_sign_hl,
      \ }

" Git wrapper
Plug 'tpope/vim-fugitive'

" Statusline improvements
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
let g:airline_detect_spell=0
let g:airline_left_alt_sep=''
let g:airline_left_sep='▓▒░'
let g:airline_powerline_fonts=1
let g:airline_right_alt_sep=''
let g:airline_right_sep='░▒▓'
let g:airline_skip_empty_sections = 1
let g:airline_mode_map = {
    \ '__' : '-',
    \ 'n'  : 'N',
    \ 'ni' : 'Ni',
    \ 'no' : 'P',
    \ 'i'  : 'I',
    \ 'ic' : 'I',
    \ 'ix' : 'I',
    \ 'R'  : 'R',
    \ 'Rv' : 'Rv',
    \ 'c'  : 'C',
    \ 'v'  : 'V',
    \ 'V'  : 'V',
    \ '' : 'V',
    \ 's'  : 'S',
    \ 'S'  : 'S',
    \ '' : 'S',
    \ 't'  : 'T',
    \ }
let g:airline#extensions#hunks#enabled=0
let g:airline#extensions#neomake#enabled=1
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#buffer_min_count=2
let g:airline#extensions#tabline#buffer_nr_format='%s '
let g:airline#extensions#tabline#buffer_nr_show=1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline#extensions#tabline#left_alt_sep=''
let g:airline#extensions#tabline#left_sep=' '
let g:airline#extensions#tabline#show_close_button=0
let g:airline#extensions#tabline#show_tab_type=0
let g:airline#extensions#tabline#tab_min_count=2
let g:airline#extensions#whitespace#enabled=1
let g:airline#extensions#whitespace#symbol='µ'
let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'

let g:airline_theme='nocturne'

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_symbols.dirty = ''
let g:airline_symbols.linenr = ''
let g:airline_symbols.notexists = ' ▼'

function! NearestMethodOrFunction() abort
  return get(b:, 'vista_nearest_method_or_function', '')
endfunction

function! AirlineInit()
  call airline#parts#define_raw('colnr', '%2c')
  call airline#parts#define_accent('colnr', 'bold')
  call airline#parts#define_raw('lsp', '%{LanguageClient#statusLine()}')
  call airline#parts#define_raw('nearest_fn', '%{NearestMethodOrFunction()}')
  let g:airline_section_x = airline#section#create_left(['nearest_fn', 'filetype', 'lsp'])
  let g:airline_section_z = airline#section#create(['colnr', ':%l'])
endfunction
augroup airline_config
  autocmd!
  autocmd VimEnter * call vista#RunForNearestMethodOrFunction()
  autocmd User AirlineAfterInit call AirlineInit()
augroup END

" Extended % matching
runtime macros/matchit.vim

" Place signs to indicate current version control diff
Plug 'mhinz/vim-signify'
let g:signify_vcs_list = ['git', 'svn', 'hg']
let g:signify_sign_change = '~'
let g:signify_sign_delete = '-'
let g:signify_update_on_focusgained = 1

" Provides command to rename the current buffer.
Plug 'danro/rename.vim'

Plug 'osyo-manga/vim-anzu'
nmap n <Plug>(anzu-n)
nmap N <Plug>(anzu-N)
nmap * <Plug>(anzu-star)
nmap # <Plug>(anzu-sharp)
let g:anzu_status_format = '%p(%i/%l) '
exe 'map <silent> <leader><leader> :AnzuClearSearchStatus \|' . maparg('<leader><leader>')
" Disable built-in search counter (it only goes up to 99, anzu goes to 1000).
set shortmess+=S

" =============================================================================
" Features
" =============================================================================

" Autocompletion
if has('nvim') && has('python3')
  function! DoRemote(arg)
    UpdateRemotePlugins
  endfunction

  Plug 'Shougo/deoplete.nvim', { 'do': function('DoRemote') }
  let g:deoplete#enable_at_startup = 1
  inoremap <expr><tab> pumvisible() ? "\<C-n>" : "\<TAB>"
  inoremap <expr><s-tab> pumvisible() ? "\<C-p>" : "\<TAB>"
endif

" Automatic completion of parenthesis, brackets, etc.
Plug 'Raimondi/delimitMate'
let g:delimitMate_expand_cr=1                 " Put new brace on newline after CR

" View highlight groups under cursor
Plug 'gerw/vim-HiLinkTrace'

" On save, create directories if they don't exist
Plug 'dockyard/vim-easydir'

" Fuzzy file finder
Plug 'junegunn/fzf', { 'dir': $XDG_DATA_HOME . '/fzf', 'do': './install --bin' }
Plug 'junegunn/fzf.vim'
let g:fzf_action = {
      \ 'ctrl-s': 'split',
      \ 'ctrl-v': 'vsplit'
      \ }
let g:fzf_preview_window = 'right:60%'
nnoremap <c-p> :Files<cr>
augroup fzf
  autocmd!
  autocmd! FileType fzf
  autocmd  FileType fzf set laststatus=0 noshowmode noruler
    \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
augroup END

" Undo tree viewer
Plug 'sjl/gundo.vim'

" Unit-testing framework
Plug 'junegunn/vader.vim'

" =============================================================================
" Language Plugins
" =============================================================================

" Language server support
Plug 'autozimu/LanguageClient-neovim', {
      \ 'branch': 'next',
      \ 'do': has('win32') ?
      \   'powershell -executionpolicy bypass -File install.ps1' : 'bash install.sh',
      \ }
let g:LanguageClient_autoStart = 1
let g:LanguageClient_settingsPath=$VIMHOME . '/lsp-settings.json'

nnoremap <silent> K :call LanguageClient_textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient_textDocument_definition()<CR>
nnoremap <silent> <leader>r :call LanguageClient_textDocument_rename()<CR>
nnoremap <silent> <leader>f :call LanguageClient_textDocument_formatting()<CR>
command! Symbols call LanguageClient_workspace_symbol()

let g:LanguageClient_diagnosticsDisplay = {
      \  1: {
      \    'name': 'Error',
      \    'texthl': s:error_hl,
      \    'signText': s:error_sign,
      \    'signTexthl': s:error_sign_hl,
      \    'virtualTexthl': s:error_text_hl,
      \  },
      \  2: {
      \    'name': 'Warning',
      \    'texthl': s:warning_hl,
      \    'signText': s:warning_sign,
      \    'signTexthl': s:warning_sign_hl,
      \    'virtualTexthl': s:warning_text_hl,
      \  },
      \  3: {
      \    'name': 'Information',
      \    'texthl': s:info_hl,
      \    'signText': s:info_sign,
      \    'signTexthl': s:info_sign_hl,
      \    'virtualTexthl': s:info_text_hl,
      \  },
      \  4: {
      \    'name': 'Hint',
      \    'texthl': s:hint_hl,
      \    'signText': s:hint_sign,
      \    'signTexthl': s:hint_sign_hl,
      \    'virtualTexthl': s:hint_text_hl,
      \  },
      \ }
let g:LanguageClient_serverCommands = {}

" Rust language server
if executable('rls')
  let g:LanguageClient_serverCommands['rust'] = ['rls', '+nightly']
endif

if executable('typescript-language-server')
  let g:LanguageClient_serverCommands['typescript'] = ['typescript-language-server', '--stdio']
endif

" Haskell omnifunc
if executable('ghc-mod')
  Plug 'eagletmt/neco-ghc', { 'for': 'haskell' }
  let g:necoghc_enable_detailed_browse=1          " Show types of symbols
endif

" Markdown automatic HTML preview
if executable('cargo')
  function! g:BuildComposer(info)
    if a:info.status !=# 'unchanged' || a:info.force
      if has('nvim')
        !cargo build --release
      else
        !cargo build --release --no-default-features --features json-rpc
      endif
    endif
  endfunction

  Plug 'euclio/vim-markdown-composer', { 'do': function('BuildComposer') }
endif

" 100+ common filetype plugins
Plug 'sheerun/vim-polyglot'
let g:polyglot_disabled = ['haskell', 'markdown']

" LaTeX
let g:LatexBox_latexmk_preview_continuously=1   " Auto-compile TeX on save
let g:LatexBox_build_dir='latexmk'              " Build files are in 'latexmk'

" Rust
let g:rustfmt_autosave=0                    " Assume that RLS handles formatting
let g:rustfmt_fail_silently=1               " Don't report rustfmt errors
let g:rustfmt_command='rustfmt +nightly'

" Language Client

" Use the language server as the formatexpr for any language that has a language
" client configured.
augroup language_client_formatting
  autocmd!
  for s:ft in keys(g:LanguageClient_serverCommands)
    exe 'autocmd FileType ' . s:ft .
          \ ' setlocal formatexpr=LanguageClient_textDocument_rangeFormatting()'
  endfor
augroup END

" View file outline in a sidebar via LSP and ctags.
Plug 'liuchengxu/vista.vim'
let g:vista#renderer#enable_icon = 0
nnoremap <leader>s :Vista!!<cr>

let g:vista_executive_for = {}
for ft in keys(g:LanguageClient_serverCommands)
  let g:vista_executive_for[ft] = 'lcn'
endfor

" =============================================================================
" Cosmetic
" =============================================================================
"
" My personal colorscheme
Plug 'euclio/vim-nocturne'
