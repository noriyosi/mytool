;; For emacs22 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(when (< emacs-major-version 23)
  ;; setting
  (transient-mark-mode 1)

  ;; functions
  (defun use-region-p ()
    (and transient-mark-mode mark-active))

  (defun isearch-occur ()
    (interactive)
    (occur isearch-string))

  ;; key-bind
  (define-key isearch-mode-map (kbd "M-s o") 'isearch-occur)
  )

;; Functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun my-add-exec-path (path)
  (setenv "PATH" (concat path path-separator (getenv "PATH")))
  (add-to-list 'exec-path path))

(defun my-keys-to-int (key)
  (if (integerp key) key -1))

(defvar my-repeater-command nil)
(defvar my-repeater-prefix-arg nil)
(defvar my-repeater-prev-key nil)
(defvar my-repeater-ignore-command
  '(execute-extended-command self-insert-command iswitchb-buffer))
(defun my-repeater ()
  (setq my-repeater-command
        (when (and (not (and isearch-mode
                             (equal isearch-string "")))
                   my-repeater-prev-key
                   (not (member last-command my-repeater-ignore-command)))
          (let* ((keys (recent-keys))
                 (prev-key (my-keys-to-int my-repeater-prev-key))
                 (real-prev-key (my-keys-to-int (aref keys (- (length keys) 2))))
                 (last-key (my-keys-to-int last-command-event))
                 (last-key-offset (- last-key ?a)))
            (when (and (< 0 prev-key)
                       (eq prev-key real-prev-key)
                       (or (eq (- prev-key ?@) (- last-key ?@))
                           (eq (- prev-key ?\A-a) last-key-offset)
                           (eq (- prev-key ?\C-a) last-key-offset)
                           (eq (- prev-key ?\H-a) last-key-offset)
                           (eq (- prev-key ?\M-a) last-key-offset)
                           (eq (- prev-key ?\s-a) last-key-offset)
                           (eq (- prev-key ?\S-a) last-key-offset)))
              (cond (my-repeater-command
                     (setq this-command my-repeater-command
                           prefix-arg my-repeater-prefix-arg)
                     my-repeater-command)
                    (t
                     (setq my-repeater-prefix-arg last-prefix-arg)
                     (setq this-command real-last-command)
                     (setq prefix-arg last-prefix-arg)
                     real-last-command))))))
  (setq my-repeater-prev-key last-command-event))

(defun my-isearch-yank-symbol ()
  (interactive)
  (let ((sym (symbol-at-point)))
    (if sym
        (progn
          (setq isearch-regexp t
                isearch-string (concat "\\_<" (regexp-quote (symbol-name sym))
                                       "\\_>")
                isearch-message (mapconcat 'isearch-text-char-description
                                           isearch-string "")
                isearch-yank-flag t))
      (ding)))
  (isearch-search-and-update))

(defun my-kill-word-or-region (arg)
  (interactive "p")
  (if (use-region-p)
      (kill-region (point) (mark))
    (backward-kill-word arg)))

(defun my-auto-hippie-expand (&optional arg)
  (interactive)
  (if (or (bolp)
          (use-region-p)
          (string-match "[^a-zA-Z0-9-_/]" (string (char-before))))
      (indent-for-tab-command arg)
    (hippie-expand arg)))

(defun genpass ()
  (interactive)
  (let ((key1 (read-passwd "key1: "))
        (key2 (completing-read "key2 (google): "
                               '("google" "atspace" "apple" "microsoft"
                                 "amazon" "livedoor" "hatena" "j-west"
                                 "ps3" "skype" "prius" "github")
                               nil nil "" "" "google" nil)))
    (kill-new (substring (sha1 (concat (sha1 key1) key2)) 0 8))))

(defun my-dired-start ()
  (interactive)
  (cond ((eq window-system 'w32)
         (w32-shell-execute "open" (dired-get-filename)))
        ((eq window-system 'ns)
         (shell-command (concat "open " "\"" (dired-get-filename) "\"")))))

;; Programable setting ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(server-start)
(add-to-list 'load-path "~/elisp")

;; Dired ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook 'dired-load-hook
          (lambda () (load "dired-x")))
(autoload 'wdired-change-to-wdired-mode "wdired")

;; Etc ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(autoload 'magit-status "magit" "" t)


;; Key-bind ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; repeat
;;(add-hook 'pre-command-hook 'my-repeater)
;;(byte-compile 'my-repeater)

;;;; Useful function
(define-key isearch-mode-map (kbd "C-l") 'my-isearch-yank-symbol)
(global-set-key (kbd "C-c C-m") 'execute-extended-command)
(global-set-key (kbd "C-w") 'my-kill-word-or-region)
(global-set-key (kbd "TAB") 'my-auto-hippie-expand)

;;;; Isearch
(when (eq (lookup-key isearch-mode-map (kbd "C-c")) 'isearch-other-control-char)
  (define-key isearch-mode-map (kbd "C-c") (make-sparse-keymap)))
(define-key isearch-mode-map (kbd "C-c o") 'isearch-occur)

;;;; Dired
(add-hook 'dired-load-hook
	  (lambda ()
	    (define-key dired-mode-map "r" 'wdired-change-to-wdired-mode)
	    (define-key dired-mode-map "z" 'my-dired-start)))

;; Mode setting ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun my-c-setting ()
  (setq indent-tabs-mode t)
  (setq tab-width 4)
  (c-set-style "stroustrup"))

(defun my-java-setting ()
  (c-set-offset 'arglist-cont-nonempty 8)
  (c-set-offset 'topmost-intro-cont 'my-topmost-intro-cont-ignore-annotation))

(defun my-topmost-intro-cont-ignore-annotation (langelem)
  (save-excursion
    (previous-line)
    (beginning-of-line)
    (if (re-search-forward "^[ \t]*@" (c-point 'eol) t) 0 4)))

(add-hook 'c-mode-hook 'my-c-setting)
(add-hook 'java-mode-hook 'my-java-setting)

;; Specific os setting ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Windows

;; UnxUtils
;;   http://sourceforge.net/projects/unxutils/files/unxutils/current/UnxUtils.zip/download
;; UnxUpdates
;;   ftp://ftp.fh-hannover.de/pandora/files/linux/UnxUpdates.zip
;;   ftp://ftp.ufanet.ru/pub/windows/unixutils/UnxUpdates.zip
;;   http://www.weihenstephan.de/~syring/win32/UnxUpdates.zip
;; Git
;;   http://code.google.com/p/msysgit/

(cond ((eq window-system 'w32)
       (setq grep-find-ignored-files '(".#*" "*~" "*.exe" "*.doc" "*.xls" "*.pdf" "*.dll")))
      ((eq window-system 'ns)
       (my-add-exec-path "/opt/local/bin")
       ;; (setq xargs-program "gxargs")
       ;; (set-default-coding-systems 'utf-8-unix)
       ;; (set-clipboard-coding-system 'utf-8)
       ;; (set-keyboard-coding-system 'utf-8)
       ;; (set-terminal-coding-system 'utf-8)
       ;; (prefer-coding-system 'utf-8-unix)
       ))

;; Customize ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector ["black" "red" "green3" "yellow3" "blue" "magenta" "cyan3" "white"])
 '(dired-recursive-copies (quote always))
 '(dired-recursive-deletes (quote always))
 '(eshell-ask-to-save-history (quote always))
 '(eshell-history-size 1000)
 '(eshell-ls-dired-initial-args (quote ("-h")))
 '(eshell-ls-exclude-regexp "~\\'")
 '(eshell-ls-initial-args "-h")
 '(eshell-ls-use-in-dired t nil (em-ls))
 '(eshell-modules-list (quote (eshell-alias eshell-basic eshell-cmpl eshell-dirs eshell-glob eshell-hist eshell-ls eshell-pred eshell-prompt eshell-rebind eshell-script eshell-smart eshell-term eshell-unix eshell-xtra)))
 '(eshell-prefer-to-shell t nil (eshell))
 '(eshell-stringify-t nil)
 '(eshell-term-name "ansi")
 '(eshell-visual-commands (quote ("vi" "top" "screen" "less" "lynx" "ssh" "rlogin" "telnet")))
 '(hippie-expand-try-functions-list (quote (try-complete-file-name-partially try-complete-file-name try-expand-all-abbrevs try-expand-dabbrev try-expand-dabbrev-all-buffers try-expand-dabbrev-from-kill try-complete-lisp-symbol-partially try-complete-lisp-symbol)))
 '(icomplete-mode t)
;; '(ido-mode (quote both) nil (ido))
 '(ido-unc-hosts (quote ido-unc-hosts-net-view))
 '(indent-tabs-mode nil)
 '(indicate-empty-lines t)
 '(initial-frame-alist (quote ((menu-bar-lines . 0) (width . 100) (height . 40) (tool-bar-lines . 0) (top . 0) (left . 0))))
 '(iswitchb-delim " | ")
 '(iswitchb-max-to-show 12)
 '(iswitchb-mode t)
 '(kill-whole-line t)
 '(line-spacing 2)
 '(ns-alternate-modifier (quote none))
 '(ns-command-modifier (quote meta))
 '(partial-completion-mode t)
 '(read-file-name-completion-ignore-case t)
 '(recentf-mode t)
 '(save-place t nil (saveplace))
 '(set-mark-command-repeat-pop t)
 '(show-paren-mode t)
 '(show-trailing-whitespace t)
 '(skk-egg-like-newline t)
 '(skk-sticky-key ";")
 '(view-read-only t)
 '(visible-bell t)
 '(which-func-modes (quote (emacs-lisp-mode c-mode c++-mode perl-mode cperl-mode python-mode makefile-mode sh-mode fortran-mode f90-mode ada-mode diff-mode java-mode)))
 '(which-function-mode t)
 '(x-select-enable-clipboard t))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(diff-added ((t (:foreground "blue"))))
 '(diff-removed ((t (:foreground "red"))))
 '(trailing-whitespace ((((class color) (background light)) (:background "linen"))))
 )

;; Font ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Monaco
;;   http://www.webdevkungfu.com/files/MONACO.TTF
;; DejaVu Sans Mono
;; Consolas
;; Inconsolata-g
;;   http://www.fantascienza.net/leonardo/ar/inconsolatag/inconsolata-g_font.zip

(let ((fonts (cond ((eq window-system 'x) '("Inconsolata-13" "Takaoゴシック"))
                   ((eq window-system 'w32) '("Inconsolata-g-11" "メイリオ"))
                   ((eq window-system 'ns) '("Monaco" "ヒラギノ丸ゴ Pro")))))
  (when fonts
    (set-frame-font (car fonts))

    ;; tool tip
    ;;(set-face-font 'variable-pitch (car fonts))

    ;; general japanese
    (set-fontset-font (frame-parameter nil 'font)
                      'japanese-jisx0208
                      `(,(cadr fonts) . "unicode-bmp"))
    ;; fullwidth tilde
    (set-fontset-font (frame-parameter nil 'font)
                      'japanese-jisx0212
                      `(,(cadr fonts) . "unicode-bmp"))
    ;; circle digit
    (set-fontset-font (frame-parameter nil 'font)
                      'japanese-jisx0213.2004-1
                      `(,(cadr fonts) . "unicode-bmp"))
    ;; halfwidth katakana
    (set-fontset-font (frame-parameter nil 'font)
                      'katakana-jisx0201
                      `(,(cadr fonts) . "unicode-bmp"))))

