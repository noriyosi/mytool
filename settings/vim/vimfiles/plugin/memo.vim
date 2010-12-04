
command! Memo call <SID>open_memo(localtime())
function! s:open_memo(time)
    exe 'edit ' . strftime($HOME.'/.vimemo/%Y%m%d.txt', a:time)

    setlocal ts=2
    setlocal sw=2
    let next = a:time+60*60*24
    let prev = a:time-60*60*24

    exe 'nnoremap <buffer> <C-n> :call <SID>search_memo('.next.', 0)<cr>'
    exe 'nnoremap <buffer> <C-p> :call <SID>search_memo('.prev.', 1)<cr>'
endfunction

function! s:search_memo(time, desc)
    let current = a:time

    let max = 365
    while max != 0
        if getfsize(strftime($HOME.'/.vimemo/%Y%m%d.txt', current)) > 0
            break
        endif

        let time_diff = 60*60*24
        if a:desc
            let time_diff = time_diff * -1
        endif

        let current = current + time_diff

        let max = max - 1
    endwhile

    if max == 0
        call confirm("Can't find file (limit 365days)")
        return
    endif

    exe "bw" .  bufnr('%')
    exe 'edit ' . strftime($HOME.'/.vimemo/%Y%m%d.txt', current)

    setlocal ts=2
    setlocal sw=2
    let next = current+60*60*24
    let prev = current-60*60*24

    exe 'nnoremap <buffer> <C-n> :call <SID>search_memo('.next.', 0)<cr>'
    exe 'nnoremap <buffer> <C-p> :call <SID>search_memo('.prev.', 1)<cr>'
endfunction

let g:my_grepmemo_word = ""
command! GrepMemo call <SID>grep_memo()
function! s:grep_memo()

    let s:word = input("word: ", g:my_grepmemo_word)
    if s:word == ""
      let s:word = g:my_grepmemo_word
    else
      let g:my_grep_word = s:word
    endif

    exe "cd ".$HOME.'/.vimemo'
    " exe "vimgrep /".s:word."/ *.txt"
    exe 'grep /i /r /c:"'.s:word.'" *.txt'
    cd -

    cwindow
    nnoremap <cr> <cr>:call <SID>setenv_memo()<cr>
endfunction

