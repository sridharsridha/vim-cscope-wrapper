" ============================================================================
" File: vim-cscope-wrapper.vim
" Arthur: Sridhar Nagarajan <sridha.in@gmail.com>
" ============================================================================
if expand("%:p") ==# expand("<sfile>:p")
  unlet! g:loaded_vim_cscope_wrapper
endif

if exists('g:loaded_vim_cscope_wrapper')
  finish
endif
let g:loaded_vim_cscope_wrapper = 1

let s:old_cpo = &cpo
set cpo&vim

if has('cscope') && \
  executable('ctags') && \
  executable('cscope')
  call vim_cscope_wrapper#init()
elseif !has('cscope')
  echomsg 'vim-cscope-wrapper.vim need cscope support'
  finish
elseif !executable('ctags')
  echomsg 'cscope not found'
  echomsg 'vim-cscope-wrapper.vim needs GNU cscope'
  finish
elseif !executable('cscope')
  echomsg 'ctags not found'
  echomsg 'vim-cscope-wrapper.vim need ctags to generate tags'
  finish
else
  " Nothing to do
endif

" AutoCmd:
augroup vim-cscope-wrapper
  autocmd!
  autocmd VimEnter *.py,*.c,*.cpp,*.h,*.hpp,*.java call vim_cscope_wrapper#autoload()
augroup END

" Commands:
command! -nargs=0 -complete=file CscopeSetup call vim_cscope_wrapper#setup()
command! -nargs=0 -complete=file CscopePurge call vim_cscope_wrapper#purge()
command! -nargs=0 -complete=file CscopeAutoLoad call vim_cscope_wrapper#autoload()

" Finish:
let &cpo = s:old_cpo

" vim: foldmethod=marker
