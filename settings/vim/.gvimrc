set iminsert=0      " 初期挿入は IM-OFF
set imsearch=0      " 初期検索は IM-OFF
set linespace=0     " 行間 (point、Osaka 以外のフォントは 2 ぐらいを設定)
set visualbell      " beep 音を止める（代わりに画面フラッシュ）
set guioptions-=m   " メニューを消す
set guioptions-=T   " ツールバーを消す
set guioptions+=a   " マウス選択や、visual 選択でクリップボードにコピー
set columns=80      " 横幅文字数
set lines=50        " 行数
set guifont=Osaka−等幅:h12
" set guifont=MS_Mincho:h12:cSHIFTJIS
" set guifont=M+2VM+IPAG_circle:h12:cSHIFTJIS
" set guifont=BDF_UM+:h9

colorscheme mycolor

" 日本語入力のカーソル色
hi CursorIM guifg=black guibg=red

" gp でクリップボードを貼り付け
nnoremap gp "*gp

