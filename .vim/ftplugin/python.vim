let maplocalleader = '\'

setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4
setlocal textwidth=80
setlocal colorcolumn=80
setlocal nosmartindent
setlocal completeopt=menu,menuone,longest,preview
autocmd InsertLeave * if pumvisible() == 0 | pclose | endif

" Remove function call
" When on a function name, removes the name and the parens around its arguments
nnoremap <LocalLeader>f diwds(

" Wrap with function call
xmap W <Plug>VSurround

" Hint: to get ASCII value put the cursor over a letter and press 'ga'

" w - input function name
let b:surround_119 = "\1Function: \1(\r)"
" l - len
let b:surround_108 = "len(\r)"
" r - range
let b:surround_114 = "range(\r)"
" e - enumerate
let b:surround_101 = "enumerate(\r)"

" Append colon to the end of line
nnoremap <silent> <LocalLeader>: :call AppendColon()<CR>
inoremap <silent> <LocalLeader>: <C-o>:call AppendColon()<CR>
