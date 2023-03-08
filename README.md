# outerspace.vim

Shows space before and after text in meaningful ways.  Indent guides are drawn for tabs or spaces at the beginning of lines, and trailing spaces can be marked as well.

This plugin requires the [`lcs-leadmultispace`](https://vimhelp.org/options.txt.html#lcs-leadmultispace) feature introduced in Vim 8.2 patch 5066.  (Similar plugins which support earlier version of Vim use the [`conceal`](https://vimhelp.org/syntax.txt.html#conceal) mechanism for this purpose.)


## Details

Tab indentation is marked at the start of each tab character so that mis-aligned tabs or extra spaces stand out.

Space indentation is marked at each multiple of [`shiftwidth()`](https://vimhelp.org/builtin.txt.html#shiftwidth%28%29), and the markers are updated automatically whenever the [`'shiftwidth'`](https://vimhelp.org/options.txt.html#%27shiftwidth%27) or [`'tabstop'`](https://vimhelp.org/options.txt.html#%27tabstop%27) option is changed.

Trailing spaces are marked when not in Insert mode.  This feature can be turned off separately (see "Options" below).


## Installation

outerspace.vim can be installed with your favorite plugin manager.  For example, with [vim-plug](https://github.com/junegunn/vim-plug), add
```
Plug 'djpohly/outerspace.vim'
```
to the appropriate section of your `.vimrc`, then restart Vim and execute `:PlugInstall` to install.


## Options

### Auto-enabling outerspace.vim

By default, outerspace.vim will be enabled for any file you load (aside from a few specific filetypes).  You can disable this by setting the following option:
```vim
let g:outerspace_auto_enable = 0
```

If you want to exempt only certain filetypes from auto-enabling, set up an ignore list:
```vim
" Defaults:
let g:outerspace_ignorelist = [
  \   'asciidoc',
  \   'gitcommit',
  \   'help',
  \   'mail',
  \   'markdown',
  \   'qf',
  \   'tex',
  \   'text',
  \   '',
  \ ]
```

You can also change an option to disable just the display of trailing spaces:
```vim
let g:outerspace_enable_trailing = 0
```


### Display characters

You can change the characters used to display tabs, space indentation, and trailing spaces to anything you like.  By default, tabs are marked with a left-aligned, solid vertical line (U+23B8), and space indentation is marked with a centered, dashed vertical line (U+2506).  The offset in alignment is intended to help make inconsistent indentation more visible.
```vim
" Defaults
let g:outerspace_tabchar = '⎸'
let g:outerspace_spacechar = '┆'
let g:outerspace_trailchar = '•'
```


## Commands

outerspace.vim provides three commands for controlling the plugin on a per-buffer basis:
```vim
:OuterSpaceEnable
:OuterSpaceDisable
:OuterSpaceToggle
```


## Notes

This plugin modifies the [`list`](https://vimhelp.org/options.txt.html#%27list%27) and [`listchars`](https://vimhelp.org/options.txt.html#%27listchars%27) options for the buffers that it runs in.  If these options are already in use, it does not yet support restoring the old versions or merging them with its own changes.

This plugin was inspired by [vim-indentguides](https://github.com/thaerkh/vim-indentguides).
