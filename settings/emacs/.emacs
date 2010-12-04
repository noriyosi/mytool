;-*- mode: Emacs-Lisp;-*-
(server-start)
(setq load-path (append '("~/elisp") load-path))

(global-set-key (kbd "C-t") (make-sparse-keymap))
(global-set-key (kbd "C-t t") 'transpose-chars)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ダウンロードメモ
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;[UnxUtils]
;;   http://downloads.sourceforge.net/project/unxutils/unxutils/current/UnxUtils.zip
;;[UnxUpdates]
;;   http://www.wzw.tum.de/~syring/win32/UnxUpdates.zip
;;[NT Emacs]
;;   http://core.ring.gr.jp/pub/GNU/emacs/windows/emacs-23.1-bin-i386.zip
;;[メイリオ]
;;  http://www.microsoft.com/downloads/details.aspx?FamilyID=f7d758d2-46ff-4c55-92f2-69ae834ac928&DisplayLang=ja
;;[BPmono]
;;  http://www.backpacker.gr/pages/fonts/fonts.asp
;;  http://www.dafont.com/bpmono.font

;;;;;;;;; 空行とコメントを除いた行数をカウント
;;find . -name \*.java -exec cat {} \; | perl -e '{local $/=undef;$f=<>;} $f =~ s#/\*.*?\*/##sg; print $f' | \grep -vE '^\s*$' | \grep -vE '^\s*//' | wc -l

;;;;;;;;; コメント削除
;;find . -name \*.java -exec perl -i -e '{local $/=undef;$f=<>;} $f =~ s#/\*.*?\*/##sg; print $f' {} \;
;;find . -name \*.java -exec sed -i 's#\s*//.*##g' {} \;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 日本語設定
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(set-language-environment "Japanese")
;; (setq explicit-shell-file-name "bash.exe")
;; (setq shell-file-name "sh.exe")
;; ;(setq shell-file-name "cmdproxy")
;; (setq shell-command-switch "-c")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; password 生成
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun genpass ()
  (interactive)
  (let ((key1 (read-passwd "key1: "))
        (key2 (completing-read "key2 (google): "
                               '("google" "atspace" "apple" "microsoft"
                                 "amazon" "livedoor" "hatena" "j-west"
                                 "ps3" "skype" "prius" "github")
                               nil nil "" "" "google" nil)))
    (kill-new (substring (sha1 (concat (sha1 key1) key2)) 0 8))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Dropbox 用のバックファイル抑止
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun my-suppress-backup-files () 
  ;;(when (string-match "/My Dropbox/" (buffer-file-name))
  (when (string-match "/Dropbox/" (buffer-file-name))
    (make-local-variable 'make-backup-files)
    (setq make-backup-files nil)
    (setq buffer-auto-save-file-name nil)))

(add-hook 'find-file-hooks 'my-suppress-backup-files)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; dired 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'dired-x)      ;dired を拡張
(autoload 'wdired-change-to-wdired-mode "wdired") ;dired で簡単リネーム
(define-key dired-mode-map "r" 'wdired-change-to-wdired-mode)
(require 'dired-details+ nil t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; key settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(global-set-key "\C-h" 'backward-delete-char-untabify)

(defun my-auto-hippie-expand (&optional arg)
  (interactive)
  (if (and (not (bolp))
           (string-match "[^[:space:]]" 
                         (char-to-string (char-before))))
      (hippie-expand arg)
    (indent-for-tab-command arg)))

;;;; viper を強化

(setq my-use-vi nil)
(when my-use-vi

;; pre setting
(setq viper-mode t)
(require 'viper)
(viper-buffer-search-enable)

(require 'hi-lock)
(setq hi-lock-file-patterns-policy 'never)

(setq my-viper-highlight-status 'off)

;; my functions 

(defun my-viper-search-next ()
  (interactive)
  (my-viper-highlight-on viper-s-string)
  (call-interactively 'viper-search-next))

(defun my-viper-search-Next ()
  (interactive)
  (my-viper-highlight-on viper-s-string)
  (call-interactively 'viper-search-Next))

(defun my-viper-isearch-backward ()
  (interactive)
  (setq viper-case-fold-search t)
  (setq viper-s-forward nil)
  (call-interactively 'isearch-backward))

(defun my-viper-isearch-forward ()
  (interactive)
  (setq viper-case-fold-search t)
  (setq viper-s-forward t)
  (call-interactively 'isearch-forward))

(defun my-viper-highlight-on (target)
  (setq viper-s-string target)
  (let ((highlight (if viper-case-fold-search
                       (replace-regexp-in-string
                        "[a-z]" (lambda (m) (format "[%s%s]" (upcase m) m))
                        target)
                     target)))
    (when (not (assoc highlight hi-lock-interactive-patterns))
      (my-viper-highlight-off)
      (highlight-regexp highlight 'highlight))))

(defun my-viper-highlight-off ()
  (interactive)
  (let ((patterns hi-lock-interactive-patterns))
    (while patterns
      (unhighlight-regexp (caar hi-lock-interactive-patterns))
      (setq patterns (cdr patterns)))))

(defun my-viper-search-word-at-point ()
  (interactive)
  (setq viper-case-fold-search nil)
  (let ((target (concat "\\_<" (thing-at-point 'symbol) "\\_>")))
    ;(my-viper-highlight-on target)
    (setq viper-s-string target)
    (setq viper-s-forward t)
    (add-to-history 'regexp-search-ring target regexp-search-ring-max)
    (viper-search target t nil)))

(defun my-viper-highlight-toggle ()
  (interactive)
  (cond ((eq my-viper-highlight-status 'on)
         (my-viper-highlight-off)
         (setq my-viper-highlight-status 'off))
        (t
         (my-viper-highlight-on viper-s-string)
         (setq my-viper-highlight-status 'on))))

(defun my-viper-undo ()
  (interactive)
  (if (eq last-command 'viper-undo)
      (viper-undo-more)
    (viper-undo)))

;; mapping
(define-key viper-insert-global-user-map [?\C-^] 'hippie-expand)
(define-key viper-insert-global-user-map "\t" 'my-auto-hippie-expand)
;(define-key viper-vi-global-user-map "n" 'my-viper-search-next)
;(define-key viper-vi-global-user-map "N" 'my-viper-search-Next)
(define-key viper-vi-global-user-map "?" 'my-viper-isearch-backward)
(define-key viper-vi-global-user-map "/" 'my-viper-isearch-forward)
(define-key viper-vi-global-user-map "*" 'my-viper-search-word-at-point)
;(define-key viper-vi-global-user-map "\C-m" 'my-viper-highlight-off)
(define-key viper-vi-global-user-map "\C-m" 'my-viper-highlight-toggle)
(define-key viper-vi-global-user-map "\C-o" 'anything)
(define-key viper-vi-global-user-map "u" 'my-viper-undo)
(define-key viper-vi-global-user-map "v" 'set-mark-command)
(define-key viper-vi-global-user-map "\C-h" 'help-command)

(require 'etags-select nil t)
(if (featurep 'etags-select)
    (define-key viper-vi-global-user-map "\C-]"
      'etags-select-find-tag-at-point)
  (define-key viper-vi-global-user-map "\C-]"
    'find-tag))

(define-key viper-vi-global-user-map "\C-t" 'pop-tag-mark)

;;;; binds hook
(add-hook 'isearch-mode-end-hook
          (lambda ()
            (setq viper-s-string isearch-string)))
;;             (my-viper-highlight-on isearch-string)))

)
(when (not my-use-vi)
(defun isearch-yank-symbol ()
  "*Put symbol at current point into search string."
  (interactive)
  (let ((sym (symbol-at-point)))
    (if sym
        (progn
          (setq isearch-regexp t
                isearch-case-fold-search nil
                isearch-string (concat "\\_<" (regexp-quote (symbol-name sym)) "\\_>")
                isearch-message (mapconcat 'isearch-text-char-description isearch-string "")
                isearch-yank-flag t))
      (ding)))
  (isearch-search-and-update))

(define-key isearch-mode-map (kbd "C-l") 'isearch-yank-symbol)
(global-set-key "\t" 'my-auto-hippie-expand)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; perl
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-to-list 'auto-mode-alist '("\\.pl\\'" . cperl-mode))
(add-to-list 'auto-mode-alist '("\\.t\\'" . cperl-mode))
(add-to-list 'interpreter-mode-alist '("perl" . cperl-mode))
(add-hook 'cperl-mode-hook
	  (lambda ()
            (and my-use-vi
                (define-key viper-vi-local-user-map (kbd "C-h f") 'cperl-perldoc))
            (local-set-key (kbd "C-h f") 'cperl-perldoc)))
(defalias 'perldoc 'cperl-perldoc)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 環境依存設定
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;各フォントの在り処

;;フォント探しは http://www.codeproject.com/KB/work/FontSurvey.aspx

;; ----------------------------------------------
;; Meadow
;; ----------------------------------------------
(defun my-meadow-setting ()
  (mw32-ime-initialize)
  (setq default-input-method "MW32-IME")
  (setq-default mw32-ime-mode-line-state-indicator "[--]")
  (setq mw32-ime-mode-line-state-indicator-list '("[--]" "[あ]" "[--]"))
  (add-hook 'mw32-ime-on-hook
            (function (lambda () (set-cursor-height 2))))
  (add-hook 'mw32-ime-off-hook
            (function (lambda () (set-cursor-height 4))))

;;;; Meadow フォント設定メモ
;;;;   1. (w32-query-get-logfont) を評価して w32-logfont の結果を得る。
;;;;   2. 得た結果を下記の設定と差し替える

  ;;メイリオ-BPmono
  (w32-add-font  "meiryo-bpmono" nil)
  (w32-change-font
   "meiryo-bpmono"
   '((spec
      ((:char-spec ascii :height any)
       strict
       (w32-logfont "BPmono" 0 -13 400 0 nil nil nil 0 1 3 49))
      ((:char-spec ascii :height any :weight bold)
       strict
       (w32-logfont "BPmono" 0 -13 700 0 nil nil nil 0 1 3 49))
      ((:char-spec ascii :height any :slant italic)
       strict
       (w32-logfont "BPmono" 0 -13 400 0 t nil nil 0 1 3 49))
      ((:char-spec ascii :height any :weight bold :slant italic)
       strict
       (w32-logfont "BPmono" 0 -13 700 0 t nil nil 0 1 3 49))
      ((:char-spec japanese-jisx0208 :height any)
       strict
       (w32-logfont "meiryo" 0 -15 400 0 nil nil nil 128 1 3 49)
       ((spacing . 1)))
      ((:char-spec japanese-jisx0208 :height any :slant italic)
       strict
       (w32-logfont "meiryo" 0 -15 400 0 t nil nil 128 1 3 49)
       ((spacing . 1)))
      ((:char-spec japanese-jisx0208 :height any :weight bold)
       strict
       (w32-logfont "meiryo" 0 -15 700 0 nil nil nil 128 1 3 49)
       ((spacing . 1)))
      ((:char-spec japanese-jisx0208 :height any :weight bold :slant italic)
       strict
       (w32-logfont "meiryo" 0 -15 700 0 t nil nil 128 1 3 49)
       ((spacing . 1))))))
  (set-face-attribute 'variable-pitch nil :font "meiryo-bpmono")

  ;; 初期フレームの設定
  (setq default-frame-alist
        (append (list '(foreground-color . "black")
                      ;;'(background-color . "LemonChiffon")
                      ;;'(background-color . "azure1")
                      '(border-color . "black")
                      '(mouse-color . "white")
                      '(cursor-color . "black")
                      '(ime-font . (w32-logfont "meiryo"
                                                0 -15 400 0 nil nil nil
                                                128 1 3 49)) ; TrueType のみ
                      '(font . "meiryo-bpmono")
                      '(width . 80)
                      '(height . 40)
                      '(top . 0)
                      '(left . 0))
                default-frame-alist))

  ;; マウスカーソルを消す設定
  (setq w32-hide-mouse-on-key t)
  (setq w32-hide-mouse-timeout 5000)

  ;; argument-editing の設定
  (require 'mw32script)
  (mw32script-init)
  (setq exec-suffix-list '(".exe" ".sh" ".pl"))
  (setq shell-file-name-chars "~/A-Za-z0-9_^$!#%&{}@`'.:()-")

  ;; shell を cygwin の bash に
  (setq explicit-shell-file-name "bash.exe")
  (setq shell-file-name "sh.exe")
  (setq shell-command-switch "-c")
  
  ;; coding-system の設定
  (add-hook 'shell-mode-hook
            (lambda ()
              (set-buffer-process-coding-system 'undecided-dos 'sjis-unix)))
  (add-hook 'shell-mode-hook 'pcomplete-shell-setup)
  )
;; ----------------------------------------------
;; ntemacs
;; ----------------------------------------------
(defun my-set-assoc-data (list key value)
  ;; リストに既に同じキーがあれば上書き、無ければ新規追加
  (let ((item (assoc key (symbol-value list))))
    (if item
        (setcdr item value)
      (add-to-list list (cons key value)))))

(defun my-ntemacs-set-font (ascii-font jis-font size mul)
  ;; フォント設定
  ;; ascii フォント、和文フォント、サイズ、倍率の順に指定する。
  (create-fontset-from-ascii-font
   (concat "-*-" ascii-font "-normal-r-normal-normal-"
           (int-to-string size) "-*-*-*-*-*-iso8859-1")
   nil
   (concat ascii-font (int-to-string size)))
    
  (let* ((encoded (encode-coding-string jis-font 'emacs-mule))
         (family (concat encoded "*"))
         (fontset (concat "fontset-" ascii-font (int-to-string size))))

    (set-fontset-font fontset 'japanese-jisx0208
                      (cons family "jisx0208-sjis"))
    (set-fontset-font fontset 'katakana-jisx0201
                      (cons family "jisx0201-katakana"))
    
    (my-set-assoc-data 'face-font-rescale-alist (concat ".*" encoded ".*") mul)
    (my-set-assoc-data 'default-frame-alist 'font fontset)
    (set-frame-font fontset)))

(defun my-ntemacs-setting ()
  (setq my-use-cygwin nil)
  (if my-use-cygwin
      (progn
        ;; cygwin
        (let* ((cygwin-root "c:/cygwin")
               (cygwin-bin (concat cygwin-root "/bin")))
          ;;    (setenv "HOME" (concat cygwin-root "/home/eric"))
          (setenv "PATH" (concat cygwin-bin ";" (getenv "PATH")))
          (add-to-list 'exec-path cygwin-bin))
        (setq shell-file-name "bash")
        (setq explicit-shell-file-name "bash")

        (and (require 'cygwin-mount nil t)
             (cygwin-mount-activate))
        
        (setq null-device "/dev/null")
        )
    (progn
      ;; UnxUtils
      (let ((unxutils-path "c:/my/apps/UnxUtils/usr/local/wbin"))
        (setenv "PATH" (concat unxutils-path ";" (getenv "PATH")))
        (add-to-list 'exec-path unxutils-path))

      ;; rgrep 用のテンプレート
      (setq grep-find-template
            "find . <X> -type f <F> -print0 | xargs -0 -s32000 grep <C> -nH -e <R> ")
      
      ;; find-dired 用のテンプレート
      (setq find-ls-option
            '("-print0 | xargs -0 -s32000 ls -ld | sed -e \"s#\\\\#/#g;\" " . "-ld"))

      ;; grep のマッチ文字列を highlight
      ;; (defadvice compilation-start (after my-grep-match activate)
      ;;   (when (eq (ad-get-arg 1) 'grep-mode)
      ;;     (save-excursion
      ;;       (set-buffer "*grep*")
      ;;       (highlight-regexp (hi-lock-process-phrase regexp) 'highlight))))

      ;;--------------------------------------------------------
      ;; Dired で Windows に関連付けられたファイルを起動する。
      ;;http://uenox.infoseek.livedoor.com/meadow/
      ;;--------------------------------------------------------
      (defun uenox-dired-winstart ()
        "Type '\\[uenox-dired-winstart]': win-start the current line's file."
        (interactive)
        (if (eq major-mode 'dired-mode)
            (let ((fname (dired-get-filename)))
              (w32-shell-execute "open" fname)
              (message "win-started %s" fname))))
      ;; dired のキー割り当て追加
      (add-hook 'dired-mode-hook
                (lambda ()
                  (define-key dired-mode-map "z" 'uenox-dired-winstart))) ;;; 関連付け
      ))

  (cond ((string= (substring emacs-version 0 2) "23")
         ;;(set-default-font "VL ゴシック-12")
         (if nil
             (progn
               (set-default-font "BPMono-9")
               ;;(set-default-font "Lucida Sans-10")
               (set-fontset-font
                (frame-parameter nil 'font)
                'japanese-jisx0208
                '("メイリオ" . "unicode-bmp")
                ;;'("VL ゴシック:weight=bold" . "unicode-bmp")
                ))
           (progn
             (setq grep-find-ignored-files nil)
             (set-default-font "BDF M+-9")))
         )
        (t
         ;; 倍率は全角と半角の比率を調整する。サイズによって最適値は異なる。
         (my-ntemacs-set-font "BPmono" "メイリオ" 13 1.3)
         ;;(my-ntemacs-set-font "Consolas" "メイリオ" 15 1.1)
         ;;(my-ntemacs-set-font "Consolas" "メイリオ" 14 1.2)
         ;;(my-ntemacs-set-font "Courier New" "ＭＳ ゴシック" 14 1.2)
         ;;(my-ntemacs-set-font "ＭＳ ゴシック" "ＭＳ ゴシック" 14 1.0)
  
         ;;(my-set-assoc-data 'default-frame-alist 'height 40)
         (my-set-assoc-data 'default-frame-alist 'height 38)
         (my-set-assoc-data 'default-frame-alist 'top 0)
         (my-set-assoc-data 'default-frame-alist 'left 0))
        ))
;; ----------------------------------------------
;; Linux
;; ----------------------------------------------
(defun my-linux-setting ()
  (when (string= (substring emacs-version 0 2)
                 "23")
    (when (window-system)
      ;;(set-default-font "VL ゴシック-11")
      (if t
        (progn
          (set-default-font "BPMono-11")
          (set-fontset-font
           (frame-parameter nil 'font)
           'japanese-jisx0208
           '("VL ゴシック" . "unicode-bmp")
           ;;'("VL ゴシック:weight=bold" . "unicode-bmp")
           ))
        (set-default-font "M+2VM+IPAG circle 11"))

      ;; 上記だけでは不十分。異なるフォントで表示されている箇所があれば
      ;; M-x describe-face で face を調べて、
      ;; (set-face-font 'face-name "VL ゴシック-12")
      ;; を追記する。もっとスマートな方法はないのかな。。

      (when my-use-vi
        ;;(define-key viper-insert-global-user-map [?\C-^] 'hippie-expand)
        (define-key viper-insert-global-user-map [ ?\C-\\ ]
          (lambda () (interactive)
            (if scim-imcontext-status
                (scim-dispatch-key-event ?\C-\ ))
            (if (scim-mode)
                (scim-dispatch-key-event ?\C-\ ))))
        (define-key viper-insert-global-user-map [zenkaku-hankaku]
          (lambda () (interactive)
            (if scim-imcontext-status
                (scim-dispatch-key-event [zenkaku-hankaku] ))
            (if (scim-mode)
                (scim-dispatch-key-event [zenkaku-hankaku] )))))
      ))
  
  (set-language-environment "Japanese")
  (set-default-coding-systems 'utf-8-unix)
  (set-clipboard-coding-system 'utf-8)
  ;;(set-clipboard-coding-system 'iso-2022-jp)
  (set-keyboard-coding-system 'utf-8)
  (set-terminal-coding-system 'utf-8)
  (prefer-coding-system 'utf-8-unix)

  (when nil
    ;; (load-library "anthy")
    ;; (setq default-input-method "japanese-anthy")

    
    ;; emacs の C-SPC を有効化
    ;; 下記をパネルのオプションのコマンドに追加して scim を無効にする
    ;;   env XMODIFIERS=@im=none 
    
    (require 'scim-bridge)
    (scim-define-common-key ?\C-\  nil) ; Use C-SPC for Set Mark command
    (scim-define-common-key ?\C-/ nil)  ; Use C-/ for Undo command
    (setq scim-cursor-color "red") ; Change cursor color depending on SCIM status
    (scim-mode 1)                  ; Turn on scim-mode automatically
    (scim-define-common-key ?\C-\\  t))
  
  )

;;;;  emacs22 のフォント設定
;; 1. options メニューの「Set Font/Fontset...」で設定したいフォントを調べる
;; 2. (frame-parameter nil 'font) を評価してフォント表現を取得
;; 3. .Xresources に下記を追記
;;    emacs*font: ここに表示された文字列をコピペ
;; 4. xrdb ~/.Xresources
;;
;; * フォントの文字列例
;;   "-Misc-Fixed-Medium-R-Normal--15-140-75-75-C-90-ISO8859-1"

;;;; emacs の C-SPC を有効化
;; 下記をパネルのオプションのコマンドに追加して scim を無効にする
;;   env XMODIFIERS=@im=none 

;;;; M+ フォントの設定
;; 1. フォントをインストール
;;   sudo apt-get install xfonts-mplus 
;; 2. .Xresources に追記
;;   Emacs.font: fontset-mplus_j12
;;   Emacs.Fontset-0: -mplus-gothic-*-r-normal--10-*-*-*-*-*-fontset-mplus_j10,\
;;   ascii:-mplus-gothic-medium-r-normal--10-*-*-*-*-*-iso8859-1
;;   Emacs.Fontset-1: -mplus-gothic-*-r-normal--12-*-*-*-*-*-fontset-mplus_j12,\
;;   ascii:-mplus-fxd-medium-r-semicondensed--12-*-*-*-*-*-iso8859-1

;; ----------------------------------------------
;; Mac (Emacs22, carbon)
;; ----------------------------------------------
(defun my-carbon-setting ()
  (set-face-attribute 'default nil :family "monaco" :height 140)
  (set-language-environment "Japanese")
  (set-default-coding-systems 'utf-8-unix)
  (set-clipboard-coding-system 'utf-8)
  ;;(set-clipboard-coding-system 'iso-2022-jp)
  (set-keyboard-coding-system 'utf-8)
  (set-terminal-coding-system 'utf-8)
  (prefer-coding-system 'utf-8-unix)
  )

;; ----------------------------------------------
;; Mac (Emacs23, cocoa)
;; ----------------------------------------------
(defun my-cocoa-setting ()
  (setenv "PATH" (concat "/opt/local/bin:" (getenv "PATH")))
  (add-to-list 'exec-path "/opt/local/bin")

  ;(set-frame-font "Monaco-13")
  (set-frame-font "BPmono-13")
  (set-fontset-font
   (frame-parameter nil 'font)
   'japanese-jisx0208
   '("ヒラギノ丸ゴ Pro" . "unicode-bmp")
   )
  (keyboard-translate ?¥ ?\\) 
  (defun viper-change-cursor-color (new-color) nil) 

  (setq xargs-program "gxargs")

  (set-default-coding-systems 'utf-8-unix)
  (set-clipboard-coding-system 'utf-8)
  (set-keyboard-coding-system 'utf-8)
  (set-terminal-coding-system 'utf-8)
  (prefer-coding-system 'utf-8-unix)
  )

;; ----------------------------------------------
;; 設定を分岐
;; ----------------------------------------------

(cond ((eq window-system 'x)
       (my-linux-setting))
      ((eq window-system 'w32)
       (if (featurep 'meadow)
           (my-meadow-setting)
         (my-ntemacs-setting))
       (setq Info-additional-directory-list '("/cygwin/usr/share/info"))
       )
      ((eq window-system 'mac)
       (my-carbon-setting))
      ((eq window-system 'ns)
       (my-cocoa-setting))
      )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; skk
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; skk の手動導入方法
;; 1. apel をインストール
;;   1.1 ダウンロード
;;     http://cvs.m17n.org/elisp/APEL/
;;   1.2 ビルド
;;     make EMACS=/home/xxx/myapp/bin/emacs
;;   1.3 配置
;;     ~/elisp/apel にビルド後のフォルダを配置
;; 2. ddskk をインストール
;;   2.1 ダウンロード
;;     http://openlab.ring.gr.jp/skk/index-j.html
;;   2.2 コンフィグファイルを修正
;;     SKK-CFG に下記を追記
;;      (setq APEL_DIR "/home/xxx/elisp/apel")
;;      (setq SKK_DATADIR "/usr/share/skk")
;;   2.3 ビルド
;;     make EMACS=/home/xxx/myapp/bin/emacs elc
;;     make EMACS=/home/xxx/myapp/bin/emacs info
;;   2.4 配置
;;     ~/elisp/ddskk にビルド後のフォルダを配置
(add-to-list 'load-path "~/elisp/apel")
(add-to-list 'load-path "~/elisp/ddskk")
(when (require 'skk-autoloads nil t)
  (global-set-key "\C-x\C-j" 'skk-mode)
  (global-set-key "\C-xj" 'skk-auto-fill-mode)
  (global-set-key "\C-xt" 'skk-tutorial)
  (setq skk-large-jisyo "~/SKK-JISYO.L")
  ;(add-hook 'isearch-mode-hook 'skk-isearch-mode-setup)
  ;(add-hook 'isearch-mode-end-hook 'skk-isearch-mode-cleanup)
  (add-hook 'isearch-mode-hook
            #'(lambda ()
                (when (and (boundp 'skk-mode)
                           skk-mode
                           skk-isearch-mode-enable)
                  (skk-isearch-mode-setup))))
  (add-hook 'isearch-mode-end-hook
            #'(lambda ()
                (when (and (featurep 'skk-isearch)
                           skk-isearch-mode-enable)
                  (skk-isearch-mode-cleanup))))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; eshell
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun tyler-eshell-view-file (file)
  "A version of `view-file' which properly respects the eshell prompt."
  (interactive "fView file: ")
  (unless (file-exists-p file) (error "%s does not exist" file))
  (let ((had-a-buf (get-file-buffer file))
        (buffer (find-file-noselect file)))
    (if (eq (with-current-buffer buffer (get major-mode 'mode-class))
            'special)
        (progn
          (switch-to-buffer buffer)
          (message "Not using View mode because the major mode is special"))
      (let ((undo-window (list (window-buffer) (window-start)
                               (+ (window-point)
                                  (length (funcall eshell-prompt-function))))))
        (switch-to-buffer buffer)
        (view-mode-enter (cons (selected-window) (cons nil undo-window))
                         'kill-buffer)))))
(defun eshell/less (&rest args)
  "Invoke `view-file' on a file. \"less +42 foo\" will go to line 42 in
    the buffer for foo."
  (while args
    (if (string-match "\\`\\+\\([0-9]+\\)\\'" (car args))
        (let* ((line (string-to-number (match-string 1 (pop args))))
               (file (pop args)))
          (tyler-eshell-view-file file)
          (goto-line line))
      (tyler-eshell-view-file (pop args)))))

(defalias 'eshell/more 'eshell/less)

(defun eshell-cd-default-directory ()
  (interactive)
  (let ((dir default-directory))
    (eshell)
    (cd dir)
    (eshell-interactive-print (concat "cd " dir "\n"))
    (eshell-emit-prompt)))

(global-set-key (kbd "C-t e") 'eshell-cd-default-directory)

(setenv "PAGER" "cat")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; anything
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(autoload 'anything "anything-config")
(eval-after-load
    "anything-config"
  '(progn
     (setq anything-sources
           '(anything-c-source-buffers
             anything-c-source-semantic
             ;;anything-c-source-call-source
             ;;anything-c-source-ctags
             ;;anything-c-source-occur
             anything-c-source-file-name-history
             ))
     (require 'anything-match-plugin)))
(global-set-key (kbd "C-t b") 'anything)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; その他
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(ffap-bindings)
;(require 'which-func)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; android
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;(setenv "PATH" (concat "/opt/local/bin:" (getenv "PATH")))

;;(setenv "PATH" (concat "/Users/foo/work/android/android-sdk-cupcake/tools:"
		      ; (getenv "PATH")))

(setq android-sdk
      "/Users/foo/android-sdk")
(setq android-project
      "/Users/foo/work/android/project/UserDict")

(defun my-compile ()
  (interactive)
  (compile (concat "cd " android-project " && ant -emacs debug")))

(defun my-start-process (name command)
  (let ((buffer-name (concat "*" name "*")))
    (and (get-buffer buffer-name)
	 (kill-buffer buffer-name))
    (apply 'start-process (append (list name buffer-name) (split-string command)))
    (display-buffer buffer-name)))

(defun my-start-emulator ()
  (interactive)
  (my-start-process "[android] emulator"
		    (concat android-sdk "/tools/emulator -vm myconfig")))
 
(defun my-android-reinstall ()
  (interactive)
  (my-start-process "[android] ant reinstall"
		    ;(concat "ant -buildfile " android-project "/build.xml reinstall")))
		    (concat "android_install.sh " android-project
			    " my.hoge")))

(global-set-key (kbd "C-t i") 'my-android-reinstall)
(global-set-key [S-f5] 'my-start-emulator)
(global-set-key (kbd "C-t c") 'my-compile)


(setq gud-jdb-command-name
      (concat "jdb -sourcepath" android-project "/src -attach localhost:"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; cygwin 対応
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(when (or (eq system-type 'cygwin)
          (eq system-type 'gnu/linux))
  (set-language-environment "Japanese")
  (set-default-coding-systems 'utf-8-unix)
  (set-clipboard-coding-system 'utf-8)
  ;;(set-clipboard-coding-system 'iso-2022-jp)
  (set-keyboard-coding-system 'utf-8)
  (set-terminal-coding-system 'utf-8)
  (setq ls-lisp-use-insert-directory-program nil)

  (when t
    (load-library "ls-lisp")
    (setq ls-lisp-dirs-first t)
    (setq dired-listing-switches "-AFl")
    (setq find-ls-option '("-exec ls -AFGl {} \\;" . "-AFGl"))
    (setq grep-find-command "find . -type f -print0 | xargs -0 -e grep -ns ")
    (require 'wdired))

  (let ((path "~/env_android/android-sdk-windows/tools"))
    (setenv "PATH" (concat path ":" (getenv "PATH")))
    (add-to-list 'exec-path path))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; unicode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; http://www.unicode.org/Public/UNIDATA/UnicodeData.txt
(let ((unidata "~/UnicodeData.txt"))
  (when (file-exists-p unidata)
    (setq describe-char-unicodedata-file unidata)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; rgrep-util
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun my-rgrep-invoker ()
  (interactive)
  (let* ((regexp (grep-read-regexp))
         (cmd (replace-regexp-in-string "grep *-nH -e \"[^\"]*\""
                                        (concat "grep -nH -e \"" regexp "\"")
                                        (car grep-find-history))))
    (switch-to-buffer "*grep*")
    (compilation-start cmd 'grep-mode)))
(global-set-key (kbd "C-t r") 'my-rgrep-invoker)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; mew
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(autoload 'mew "mew" nil t)
(autoload 'mew-send "mew" nil t)

;; Optional setup (Read Mail menu for Emacs 21):
(if (boundp 'read-mail-command)
    (setq read-mail-command 'mew))

;; Optional setup (e.g. C-xm for sending a message):
(autoload 'mew-user-agent-compose "mew" nil t)
(if (boundp 'mail-user-agent)
    (setq mail-user-agent 'mew-user-agent))
(if (fboundp 'define-mail-user-agent)
    (define-mail-user-agent
      'mew-user-agent
      'mew-user-agent-compose
      'mew-draft-send-message
      'mew-draft-kill
      'mew-send-hook))

;; ex. "hoge fuga" <xyzzy@server.com>

(setq mew-name "hoge fuga") ;; (user-full-name)
(setq mew-user "xyzzy") ;; (user-login-name)
(setq mew-mail-domain "server.com")
(setq mew-pop-user "xyzzy")
(setq mew-smtp-user "xyzzy")
(setq mew-smtp-server "192.168.1.1") ;; if not localhost
(setq mew-pop-server "192.168.1.1") ;; if not localhost
(setq mew-use-cached-passwd t)
(setq mew-pop-delete nil)
(setq mew-use-biff t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; semantic
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(semantic-mode 1)
(global-semantic-highlight-func-mode 1)
(global-semantic-stickyfunc-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; auto-install 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'auto-install nil t)
(setq auto-install-directory "~/elisp/")
(require 'dired-details+ nil t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; etc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(global-set-key (kbd "C-t g") 'beginning-of-buffer)
(global-set-key (kbd "C-t G") 'end-of-buffer)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; customize
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(c-default-style (quote ((c-mode . "linux") (java-mode . "java") (awk-mode . "awk") (other . "gnu"))))
 '(column-number-mode t)
 '(cperl-indent-level 4)
 '(dired-recursive-copies (quote always))
 '(dired-recursive-deletes (quote always))
 '(eshell-ask-to-save-history (quote always))
 '(eshell-cmpl-ignore-case t)
 '(eshell-command-completions-alist (quote (("acroread" . "\\.pdf\\'") ("xpdf" . "\\.pdf\\'") ("ar" . "\\.[ao]\\'") ("gcc" . "\\.[Cc]\\([Cc]\\|[Pp][Pp]\\)?\\'") ("g++" . "\\.[Cc]\\([Cc]\\|[Pp][Pp]\\)?\\'") ("cc" . "\\.[Cc]\\([Cc]\\|[Pp][Pp]\\)?\\'") ("CC" . "\\.[Cc]\\([Cc]\\|[Pp][Pp]\\)?\\'") ("acc" . "\\.[Cc]\\([Cc]\\|[Pp][Pp]\\)?\\'") ("bcc" . "\\.[Cc]\\([Cc]\\|[Pp][Pp]\\)?\\'") ("readelf" . "\\(\\`[^.]*\\|\\.\\([ao]\\|so\\)\\)\\'") ("objdump" . "\\(\\`[^.]*\\|\\.\\([ao]\\|so\\)\\)\\'") ("nm" . "\\(\\`[^.]*\\|\\.\\([ao]\\|so\\)\\)\\'") ("gdb" . "\\`\\([^.]*\\|a\\.out\\)\\'") ("dbx" . "\\`\\([^.]*\\|a\\.out\\)\\'") ("sdb" . "\\`\\([^.]*\\|a\\.out\\)\\'"))))
 '(eshell-history-size 10000)
 '(eshell-ls-dired-initial-args (quote ("-h")))
 '(eshell-ls-exclude-regexp "~\\'")
 '(eshell-ls-initial-args "-h")
 '(eshell-modules-list (quote (eshell-alias eshell-basic eshell-cmpl eshell-dirs eshell-glob eshell-hist eshell-ls eshell-pred eshell-prompt eshell-rebind eshell-script eshell-smart eshell-term eshell-unix eshell-xtra)))
 '(eshell-prefer-to-shell t nil (eshell))
 '(eshell-prompt-function (lambda nil (concat (eshell/pwd) (if (= (user-uid) 0) "
# " "
$ "))))
 '(eshell-prompt-regexp "^[#$] ")
 '(eshell-stringify-t nil)
 '(eshell-term-name "ansi")
 '(eshell-visual-commands (quote ("vi" "top" "screen" "less" "lynx" "ssh" "rlogin" "telnet")))
 '(gud-gdb-command-name "gdb --annotate=1")
 '(hippie-expand-try-functions-list (quote (try-complete-file-name-partially try-complete-file-name try-expand-all-abbrevs try-expand-dabbrev try-expand-dabbrev-all-buffers try-expand-dabbrev-from-kill try-complete-lisp-symbol-partially try-complete-lisp-symbol)))
 '(history-length 200)
 '(icomplete-mode t)
 '(indent-tabs-mode nil)
 '(indicate-empty-lines t)
 '(iswitchb-mode t)
 '(large-file-warning-threshold nil)
 '(line-spacing 4)
 '(mouse-wheel-scroll-amount (quote (1 ((shift) . 1) ((control)))))
 '(ns-alternate-modifier (quote none))
 '(ns-command-modifier (quote meta))
 '(partial-completion-mode t)
 '(read-buffer-completion-ignore-case t)
 '(read-file-name-completion-ignore-case t)
 '(recentf-max-saved-items 200)
 '(recentf-mode t)
 '(save-place t nil (saveplace))
 '(set-mark-command-repeat-pop t)
 '(show-paren-mode t)
 '(skk-auto-insert-paren t)
 '(skk-egg-like-newline t)
 '(skk-sticky-key ";")
 '(skk-use-viper t)
 '(tool-bar-mode nil)
 '(vc-handled-backends (quote (Git RCS CVS SVN SCCS Bzr Hg Arch)))
 '(view-read-only t)
 '(viper-ESC-key "" t)
 '(viper-ESC-keyseq-timeout 0)
 '(viper-auto-indent nil)
 '(viper-buffer-search-char 103)
 '(viper-case-fold-search t)
 '(viper-delete-backwards-in-replace t)
 '(viper-emacs-state-mode-list (quote (custom-mode dired-mode efs-mode tar-mode browse-kill-ring-mode recentf-mode recentf-dialog-mode occur-mode mh-folder-mode gnus-group-mode gnus-summary-mode completion-list-mode help-mode Info-mode Buffer-menu-mode compilation-mode rcirc-mode jde-javadoc-checker-report-mode view-mode vm-mode vm-summary-mode etags-select-mode)))
 '(viper-ex-style-editing nil)
 '(viper-fast-keyseq-timeout 0)
 '(viper-no-multiple-ESC nil)
 '(viper-shift-width 4)
 '(viper-syntax-preference (quote extended))
 '(viper-vi-style-in-minibuffer nil)
 '(viper-want-ctl-h-help nil)
 '(visible-bell t)
 '(x-select-enable-clipboard t))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(diff-added ((t (:foreground "blue"))))
 '(diff-removed ((t (:foreground "red"))))
 '(semantic-decoration-on-unknown-includes ((((class color) (background light)) (:background "#ffeeee"))))
 '(viper-minibuffer-emacs ((((class color)) nil))))

(put 'narrow-to-region 'disabled nil)

(put 'downcase-region 'disabled nil)
