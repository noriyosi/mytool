" set wildmenu
" set smartindent
" filetype plugin indent on
" 
" let @g='yiw:grep " *:cw'
" 
" vnoremap * "zy/\V<C-r>z<cr>
" nnoremap <silent> <cr> :noh<cr><cr>
" 
" set ignorecase
" set smartcase
" 
" syntax on
" set background=dark
" set hlsearch
" set incsearch
" set wildmode=list:longest,full

"""""""""""""""""""""""""""""""""""""""""

"-- 2008/10/01: 文字コード周り見直し
"-- 2008/09/03: スクロール補助 (space -> page down, bs -> page up)
"-- 2008/04/28: fencs の並び順を修正。utf-8 の優先順位を上げた。

""" 文字コード
set enc=utf-8           " vim 内部文字コード: Mac/linux=utf-8, Windows=cp932
set fencs=              " 空白設定すると常に enc で開く（file open 速度上昇）
set langmenu=japanese

" 文字コード判定コマンドを定義（全角文字が化けたら :Fenc を実行）
command Fenc call s:Fenc()
function! s:Fenc()
    if &modified
        echo "ERR: No write since last change"
    else
        set fencs=iso-2022-jp,utf-8,euc-jp,cp932,ucs-2le,ucs-2
        exec "se fencs-=".&enc
        e!
        set fencs=
    endif
endfunction


""" インデント
set smartindent     " インデント調整あり、コメント維持
set shiftwidth=4    " tab 文字の入力幅
set tabstop=4       " tab 文字の表示幅
set expandtab       " tab を空白文字に置き換え

""" 削除
set backspace=indent,eol,start  " BS で indent,改行,挿入開始前を削除
set smarttab                    " BS でインデント幅を削除

""" 検索
set hlsearch        " 検索文字列を色づけ
set ignorecase      " 大文字小文字を判別しない
set smartcase       " でも大文字小文字が混ざって入力されたら区別する
set incsearch       " インクリメンタルサーチ

""" バックアップ
set backup                  " ファイル上書きでバックアップファイルを作成
" set backupdir=/vim_back     " バックアップファイルの保存場所
" set directory=/vim_back     " 一時ファイルの保存場所

""" 表示
set background=dark            " 背景の明るさ。light or dark。（配色に影響）
syntax on                       " シンタックスの色づけ有効
set ruler                       " 左下に行列位置を表示
set showcmd                     " 入力中のコマンド（キー）を右下に表示
set wildmenu                    " コマンド入力をタブで補完
set wildmode=list:longest,full  " 補完動作（リスト表示で最長一致、その後選択）
set showmatch                   " 括弧の入力で対応する括弧を一瞬強調

""" その他
set mouse=a                 " ターミナルのマウスを有効
set hidden                  " 編集中に他ファイルを開ける (undo 履歴は消えない)
filetype plugin indent on   " ファイル別 plugin (~/.vim/ftplugin/拡張子.vim)

""" 機能追加
" enter で検索ハイライトをクリア
nnoremap <silent> <cr> :noh<cr><cr>
" visual 選択中に * で選択文字列を検索
vnoremap * y/\V<c-r>=substitute(escape(@@,"/\\"),"\n","\\\\n","ge")<cr><cr>gV

""" オリジナルコマンド追加（例）
command TimeStamp call s:TimeStamp()
function! s:TimeStamp()
   call append(".", strftime("%Y/%m/%d %H:%M"))
endfunction

"""""""""""""""" vim online : tip #305
