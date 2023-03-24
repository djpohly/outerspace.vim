" Title:   vim-outerspace
" Author:  Devin J. Pohly
" License: Apache 2.0
" URL:     https://github.com/djpohly/vim-outerspace
"
" Makes spaces before and after text visible in a convenient way.  Lines are
" shown on the left to track indent levels, and (optionally) trailing spaces
" are marked when not in Insert mode.
"
" Inspired by vim-indentguides by Thaer Khawaja:
"   https://github.com/thaerkh/vim-indentguides

if !has("patch-8.2.5066") && !has("nvim")
  echoe "vim-outerspace requires Vim 8.2 patch 5066 or Neovim"
  finish
endif

let g:outerspace_auto_enable = get(g:, 'outerspace_auto_enable', 1)
let g:outerspace_enable_trailing = get(g:, 'outerspace_enable_trailing', 1)
let g:outerspace_ignorelist = get(g:, 'outerspace_ignorelist', [
  \   'asciidoc',
  \   'gitcommit',
  \   'help',
  \   'mail',
  \   'markdown',
  \   'qf',
  \   'tex',
  \   'text',
  \   '',
  \ ])
" The non-alignment between these two defaults is intentional, to help spot
" inconsistent indentation.
let g:outerspace_tabchar = get(g:, 'outerspace_tabchar', '⎸')
let g:outerspace_spacechar = get(g:, 'outerspace_spacechar', '┆')
let g:outerspace_trailchar = get(g:, 'outerspace_trailchar', '•')

" Hex-escapes the characters ',' and ':' for an option value
function! s:EscapeValue(str)
  return substitute(substitute(a:str, ',', '\\x2c', 'g'), ':', '\\x3a', 'g')
endfunction

" Converts a 'key:val,key:val' style list option to a dictionary
function! s:ListOptionFromDict(dict)
  let l:strlist = map(items(a:dict), {_, kv -> kv[0] . ':' . s:EscapeValue(kv[1])})
  return join(l:strlist, ',')
endfunction

" Converts a dictionary to a 'key:val,key:val' style list option
function! s:DictFromListOption(str)
  let l:dict = {}
  for item in split(a:str, ',')
    let l:idx = stridx(l:item, ':')
    if l:idx == -1
      let l:dict[l:item] = ''
    else
      let l:dict[l:item[0 : l:idx - 1]] = l:item[l:idx + 1:]
    endif
  endfor
  return l:dict
endfunction

" Turns on trailing space display (e.g. when leaving Insert mode)
function! s:ShowTrailingSpaces()
  let l:lcsdict = s:DictFromListOption(&listchars)
  let l:lcsdict['trail'] = g:outerspace_trailchar
  let &l:listchars = s:ListOptionFromDict(l:lcsdict)
endfunction

" Turns on trailing space display (e.g. when entering Insert mode)
function! s:HideTrailingSpaces()
  let l:lcsdict = s:DictFromListOption(&listchars)
  if has_key(l:lcsdict, 'trail')
    call remove(l:lcsdict, 'trail')
  endif
  let &l:listchars = s:ListOptionFromDict(l:lcsdict)
endfunction

" Run to update our lcs-leadmultispace setting when shiftwidth or tabstop
" changes.
function! s:FixShiftWidth()
  " Both shiftwidth and tabstop are buffer-local, so we only need to check the
  " current buffer.  If the plugin isn't enabled there, do nothing.
  if !get(b:, 'outerspace_enabled', 0)
    return
  endif

  let l:lcsdict = s:DictFromListOption(&listchars)
  let l:lcsdict['leadmultispace'] = g:outerspace_spacechar . repeat(' ', shiftwidth() - 1)
  let &l:listchars = s:ListOptionFromDict(l:lcsdict)
endfunction

" Enables the plugin for the current buffer
function! s:EnableOuterSpace()
  " Function is idempotent

  let l:lcsdict = s:DictFromListOption(&listchars)
  let l:lcsdict['tab'] = g:outerspace_tabchar . ' '
  let l:lcsdict['lead'] = g:outerspace_spacechar
  let l:lcsdict['leadmultispace'] = g:outerspace_spacechar . repeat(' ', shiftwidth() - 1)
  if g:outerspace_enable_trailing
    let l:lcsdict['trail'] = g:outerspace_trailchar
  endif
  let &l:listchars = s:ListOptionFromDict(l:lcsdict)

  " Define buffer-local autocmds
  augroup OuterSpace
    autocmd! * <buffer>
    if g:outerspace_enable_trailing
      " Hide trailing-space display while Insert mode is active
      autocmd InsertEnter <buffer> call s:HideTrailingSpaces()
      autocmd InsertLeave <buffer> call s:ShowTrailingSpaces()
    endif
  augroup END

  setlocal list

  let b:outerspace_enabled = 1
endfunction

" Disables the plugin for the current buffer
function! s:DisableOuterSpace()
  let b:outerspace_enabled = 0

  setlocal nolist

  let l:lcsdict = s:DictFromListOption(&listchars)
  silent! unlet l:lcsdict['tab']
  silent! unlet l:lcsdict['lead']
  silent! unlet l:lcsdict['leadmultispace']
  if g:outerspace_enable_trailing
    silent! unlet l:lcsdict['trail']
  endif
  let &l:listchars = s:ListOptionFromDict(l:lcsdict)

  " Clear buffer-local autocmds
  augroup OuterSpace
    autocmd! * <buffer>
  augroup END
endfunction

function! s:ToggleOuterSpace()
  if get(b:, 'outerspace_enabled', 0)
    call s:DisableOuterSpace()
  else
    call s:EnableOuterSpace()
  endif
endfunction

function! s:AutoEnableOuterSpace()
  if !g:outerspace_auto_enable || exists("b:outerspace_enabled") || index(g:outerspace_ignorelist, &filetype) != -1
    " skip if auto-enable is off, if the buffer has already been loaded, or if this is an ignored filetype
    return
  endif

  call s:EnableOuterSpace()
endfunction

augroup OuterSpace
  autocmd!
  autocmd BufWinEnter * call s:AutoEnableOuterSpace()
  " The OptionSet autocmd doesn't work on a per-buffer basis
  autocmd OptionSet shiftwidth call s:FixShiftWidth()
  autocmd OptionSet tabstop call s:FixShiftWidth()
augroup END

command! OuterSpaceEnable call s:EnableOuterSpace()
command! OuterSpaceDisable call s:DisableOuterSpace()
command! OuterSpaceToggle call s:ToggleOuterSpace()

" vim: ts=2 sw=2 et
