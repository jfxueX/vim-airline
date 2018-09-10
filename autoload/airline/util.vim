" MIT License. Copyright (c) 2013-2018 Bailey Ling et al.
" vim: et ts=2 sts=2 sw=2

" TODO: Try to cache winwidth(0) function
" e.g. store winwidth per window and access that, only update it, if the size
" actually changed.
scriptencoding utf-8

call airline#init#bootstrap()
let s:spc = g:airline_symbols.space

function! airline#util#shorten(text, winwidth, minwidth, ...)
  if winwidth(0) < a:winwidth && len(split(a:text, '\zs')) > a:minwidth
    if get(a:000, 0, 0)
      " shorten from tail
      return '…'.matchstr(a:text, '.\{'.a:minwidth.'}$')
    else
      " shorten from beginning of string
      return matchstr(a:text, '^.\{'.a:minwidth.'}').'…'
    endif
  else
    return a:text
  endif
endfunction

function! airline#util#wrap(text, minwidth)
  if a:minwidth > 0 && winwidth(0) < a:minwidth
    return ''
  endif
  return a:text
endfunction

function! airline#util#append(text, minwidth)
  if empty(a:text) || (a:minwidth > 0 && winwidth(0) < a:minwidth)
    return ''
  endif
  let prefix = s:spc == "\ua0" ? s:spc : s:spc.s:spc
  return prefix . g:airline_left_alt_sep . s:spc . a:text
endfunction

function! airline#util#warning(msg)
  echohl WarningMsg
  echomsg "airline: ".a:msg
  echohl Normal
endfunction

function! airline#util#prepend(text, minwidth)
  if a:minwidth > 0 && winwidth(0) < a:minwidth
    return ''
  endif
  return empty(a:text) ? '' : a:text.s:spc.g:airline_right_alt_sep.s:spc
endfunction

if v:version >= 704
  function! airline#util#getwinvar(winnr, key, def)
    return getwinvar(a:winnr, a:key, a:def)
  endfunction
else
  function! airline#util#getwinvar(winnr, key, def)
    let winvals = getwinvar(a:winnr, '')
    return get(winvals, a:key, a:def)
  endfunction
endif

if v:version >= 704
  function! airline#util#exec_funcrefs(list, ...)
    for Fn in a:list
      let code = call(Fn, a:000)
      if code != 0
        return code
      endif
    endfor
    return 0
  endfunction
else
  function! airline#util#exec_funcrefs(list, ...)
    " for 7.2; we cannot iterate the list, hence why we use range()
    " for 7.3-[97, 328]; we cannot reuse the variable, hence the {}
    for i in range(0, len(a:list) - 1)
      let Fn{i} = a:list[i]
      let code = call(Fn{i}, a:000)
      if code != 0
        return code
      endif
    endfor
    return 0
  endfunction
endif

" Compatibility wrapper for strchars, in case this vim version does not
" have it natively
function! airline#util#strchars(str)
  if exists('*strchars')
    return strchars(a:str)
  else
    return strlen(substitute(a:str, '.', 'a', 'g'))
  endif
endfunction

let s:ignore_buf_pat = ""
let s:ignore_buf_max_name_len = 0

function! airline#util#ignore_buf(name)
  if empty(s:ignore_buf_pat)
    let bnames = ['gundo', 'undotree', 'vimfiler', 'tagbar', 'nerd_tree', 'startify']
    let bnames += split(get(g:, 'airline#ignore_bufadd_pat', ''), '|')
    let bnames += split(get(g:, 'airline#extensions#tabline#ignore_bufadd_pat', ''), '|')
    for bname in bnames
      let len = strlen(bname)
      if len > s:ignore_buf_max_name_len
        let s:ignore_buf_max_name_len = len
      endif
    endfor
    let s:ignore_buf_pat = '\c\v' . join(bnames, '|')
  endif

  if a:name[s:ignore_buf_max_name_len:s:ignore_buf_max_name_len] !=# ''
    return 0
  endif
  let ret = match(a:name, s:ignore_buf_pat) > -1
  return ret

  "let pat = '\c\v'. get(g:, 'airline#ignore_bufadd_pat', '').
  "      \ get(g:, 'airline#extensions#tabline#ignore_bufadd_pat', 
  "      \ 'gundo|undotree|vimfiler|tagbar|nerd_tree|startify')
  "return match(a:name, pat) > -1
endfunction

function! airline#util#has_fugitive()
  return exists('*fugitive#head') || exists('*FugitiveHead')
endfunction

function! airline#util#has_lawrencium()
  return exists('*lawrencium#statusline')
endfunction

function! airline#util#has_vcscommand()
  return get(g:, 'airline#extensions#branch#use_vcscommand', 0) && exists('*VCSCommandGetStatusLine')
endfunction

function! airline#util#has_custom_scm()
  return !empty(get(g:, 'airline#extensions#branch#custom_head', ''))
endfunction
