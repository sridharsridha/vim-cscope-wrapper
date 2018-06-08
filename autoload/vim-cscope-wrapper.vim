" ============================================================================
" File: vim-cscope-wrapper.vim
" Author: Sridhar Nagarajan <sridha.in@gmail.com>
" Description: This file contains command function for cscope wrapper plugin
" ============================================================================
"Get scm repo info
function! s:cscope_get_scm_info() abort
  let l:scm = {'type': '', 'root': ''}

  "Supported scm repo
  let l:scm_list = ['.git', '.hg', '.svn']

  "Detect scm type
  for l:item in l:scm_list
    let l:dir = finddir(l:item, '.;')
    if !empty(l:dir)
      let l:scm['type'] = l:item
      let l:scm['root'] = l:dir
      break
    endif
  endfor

  "Not a scm repo, return
  if empty(l:scm['type'])
    return l:scm
  endif

  "Get scm root
  let l:scm['root'] = substitute(l:scm['root'], '/' . l:scm['type'], '', 'g')

  return l:scm
endfunction

function! s:cscope_find_project_root() abort
  if !exists('s:project_root')
    let s:project_root = ''
  endif

  "If it is scm repo, use scm folder as project root
  let l:scm = s:cscope_get_scm_info()
  if !empty(l:scm['type'])
    return l:scm['root']
  endif

  if empty(s:project_root)
    if winbufnr(0) != -1
      let s:project_root = getcwd()
    else
      let s:porject_root = fnamemodify(bufname(winbufnr(0)), ':p:h')
    endif
  endif
  return s:project_root
endfunction

function! s:cscope_echo(str) abort
  echohl 'Title'
  echomsg a:str
  echohl None
endfunction

" Generate cscope and ctags database for the specified directory
function! s:cscope_db_generate(src_path)
  silent !find a:src_path -name '*.aidl' -o -name '*.cc' -o -name '*.h' -o -name '*.hpp' -o -name '*.c' -o -name '*.cpp' -o -name '*.java' -o -name '*.py' > a:src_path.'/cscope.files'
  silent !cscope -bq -i a:src_path.'/cscope.files' -f a:src_path.'/cscope.out'
  silent !ctags -R --exclude=.svn --exclude=.git -L a:src_path.'/cscope.files' -f a:src_path.'/tags'
endfunction

" Load a cscope database
function! s:cscope_db_load(database_path)
  if filereadable(a:database_path. "/" . a:database_name)
    set nocscopeverbose
    silent execute "cs add ".a:database_path."/cscope.out ".a:database_path
    set cscopeverbose
  endif
endfunction

" Unloads a cscope database
function! s:cscope_db_unload(database_path)
  " Use exact match for path and name to kill cscope connection
  if cscope_connection(4, "cscope.out", a:database_path)
    set nocscopeverbose
    silent execute "cs kill ".a:database_path."/cscope.out"
    set cscopeverbose
  endif
endfunction


" Reset the existing connections
function! s:cscope_db_reset()
  set nocscopeverbose
  silent execute "cs reset"
  set cscopeverbose
endfunction

" Search for database file upward and return database folder path
function! s:cscope_find_nearest_db(start_dir, stop_dir)
  let l:current_dir = a:start_dir

  while (strlen(l:current_dir) > 0)
    if filereadable(l:current_dir."/cscope.out")
      return l:current_dir
    endif

    let l:current_dir_name_len = match(l:current_dir, "/[^/]*$")
    if l:current_dir_name_len == -1
      break
    endif

    let l:current_dir = strpart(l:current_dir, 0, l:current_dir_name_len)
    if l:current_dir == a:stop_dir
      break
    endif
  endwhile

  return "Nothing"
endfunction

" Update the cscope database
function! s:cscope_db_update(database_path)
  if !filereadable(a:database_path.'/cscope.out')
    call s:cscope_echo('cscope.out not found in ' . a:database_path)
    return
  endif
  if !cscope_connection(4, "cscope.out", a:database_path)
    call s:cscope_echo('cscope connection does not exist!')
    return
  endif
  call s:cscope_db_generate(a:database_path)
  call s:cscope_db_reset()
endfunction

" Setup cscope connetion, update if connection exist or build if not db found
function! vim_cscope_wrapper#setup()
  let l:project_root = s:cscope_find_project_root()
  let l:database_path = s:cscope_find_nearest_db(l:project_root, "/")

  if l:database_path != 'Nothing'
    if cscope_connection(4, "cscope.out", l:database_path)
      let l:update_now = input('Already connection exists!. Do you want to update now?(Y/N)')
      silent! redraw
      if toupper(l:update_now) == 'Y'
        call s:cscope_db_update(l:database_path)
        call s:cscope_echo('cscope connection updated! '.l:database_path.'/cscope.out')
      else
        call s:cscope_echo('cscope connection NOT updated! '.l:database_path.'/cscope.out')
      endif
    else
      call s:cscope_db_load(l:database_path)
      call s:cscope_echo('cscope connection loaded! '.l:database_path.'/cscope.out')
    endif
  else
    let l:build_now = input('No cscope database found!. Do you want to build now?(Y/N)')
    silent! redraw
    if toupper(l:build_now) == 'Y'
      call s:cscope_db_generate(l:project_root)
      call s:cscope_db_load(l:project_root)
      call s:cscope_echo('cscope database generated and loaded! '.l:project_root.'/cscope.out')
    else
      call s:cscope_echo('cscope database NOT loaded! '.l:project_root.'/cscope.out')
    endif
  endif
endfunction

" Setup cscope connection find and load
function! vim_cscope_wrapper#autoload()
  let l:project_root = s:cscope_find_project_root()
  let l:database_path = s:cscope_find_nearest_db(l:project_root, "/")

  if l:database_path != 'Nothing'
    call s:cscope_db_load(l:database_path)
    call s:cscope_echo('cscope connection loaded! '.l:database_path.'/cscope.out')
  endif
endfunction

" Unload all cscope database connections
function! vim_cscope_wrapper#purge()
  set nocscopeverbose
  silent execute "cs kill -1"
  set cscopeverbose
endfunction

command! -nargs=0 CscopeSetup :call <sid>cscope_db_setup()
command! -nargs=0 CscopePurge :call <sid>cscope_db_purge()

nmap <leader>ri :call <sid>CscopeDatabaseInit()<cr>
nmap <leader>rd :call <sid>CscopeDatabaseUnloadAll()<cr>

"nmap <leader>rb :call neomakemp#RunCommand(l:gen_cscope_files.'&&cscope -Rbkq -i '.l:cscopefiles, function('<SID>AddCscopeOut'),[0])

" The following maps all invoke one of the following cscope search types:
"   's'   symbol: find all references to the token under cursor
"   'g'   global: find global definition(s) of the token under cursor
"   'c'   calls:  find all calls to the function name under cursor
"   't'   text:   find all instances of the text under cursor
"   'e'   egrep:  egrep search for the word under cursor
"   'f'   file:   open the filename under cursor
"   'i'   includes: find files that include the filename under cursor
"   'd'   called: find functions that function under cursor calls
nmap <C-\>s :cs find s <C-R>=expand("<cword>")<cr><cr>
nmap <C-\>g :cs find g <C-R>=expand("<cword>")<cr><cr>
nmap <C-\>c :cs find c <C-R>=expand("<cword>")<cr><cr>
nmap <C-\>t :cs find t <C-R>=expand("<cword>")<cr><cr>
nmap <C-\>e :cs find e <C-R>=expand("<cword>")<cr><cr>
nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<cr><cr>
nmap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<cr>$<cr>
nmap <C-\>d :cs find d <C-R>=expand("<cword>")<cr><cr>

map <C-@>s :vert scs find s <C-R>=expand("<cword>")<cr><cr>
map <C-@>g :vert scs find g <C-R>=expand("<cword>")<cr><cr>
map <C-@>c :vert scs find c <C-R>=expand("<cword>")<cr><cr>
map <C-@>t :vert scs find t <C-R>=expand("<cword>")<cr><cr>
map <C-@>e :vert scs find e <C-R>=expand("<cword>")<cr><cr>
map <C-@>f :vert scs find f <C-R>=expand("<cfile>")<cr><cr>
map <C-@>i :vert scs find i ^<C-R>=expand("<cfile>")<cr>$<cr>
map <C-@>d :vert scs find d <C-R>=expand("<cword>")<cr><cr>

nmap <C-@><C-@>s :scs find s <C-R>=expand("<cword>")<cr><cr>
nmap <C-@><C-@>g :scs find g <C-R>=expand("<cword>")<cr><cr>
nmap <C-@><C-@>c :scs find c <C-R>=expand("<cword>")<cr><cr>
nmap <C-@><C-@>t :scs find t <C-R>=expand("<cword>")<cr><cr>
nmap <C-@><C-@>e :scs find e <C-R>=expand("<cword>")<cr><cr>
nmap <C-@><C-@>f :scs find f <C-R>=expand("<cfile>")<cr><cr>
nmap <C-@><C-@>i :scs find i ^<C-R>=expand("<cfile>")<cr>$<cr>
nmap <C-@><C-@>d :scs find d <C-R>=expand("<cword>")<cr><cr>

