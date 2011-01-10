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
  (let ((expanded-path (expand-file-name path)))
    (setenv "PATH" (concat expanded-path path-separator (getenv "PATH")))
    (add-to-list 'exec-path expanded-path)))

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

(setq my-repeatable-command
  '(scroll-up scroll-down isearch-repeat-forward isearch-repeat-backward undo))

(defun my-repeat-or-period (N)
  (interactive "p")
  (if (member last-command my-repeatable-command)
      (let ((repeat-on-final-keystroke t)
            ;;(repeat-message-function 'ignore)
            )
        (repeat last-prefix-arg))
    (if isearch-mode
        (isearch-printing-char)
      (self-insert-command N))))

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

;; http://www.emacswiki.org/cgi-bin/wiki/ImenuMode#toc10
(defun ido-goto-symbol (&optional symbol-list)
  "Refresh imenu and jump to a place in the buffer using Ido."
  (interactive)
  (unless (featurep 'imenu)
    (require 'imenu nil t))
  (cond
   ((not symbol-list)
    (let ((ido-mode ido-mode)
          (ido-enable-flex-matching
           (if (boundp 'ido-enable-flex-matching)
               ido-enable-flex-matching t))
          name-and-pos symbol-names position)
      (unless ido-mode
        (ido-mode 1)
        (setq ido-enable-flex-matching t))
      (while (progn
               (imenu--cleanup)
               (setq imenu--index-alist nil)
               (ido-goto-symbol (imenu--make-index-alist))
               (setq selected-symbol
                     (ido-completing-read "Symbol? " symbol-names))
               (string= (car imenu--rescan-item) selected-symbol)))
      (unless (and (boundp 'mark-active) mark-active)
        (push-mark nil t nil))
      (setq position (cdr (assoc selected-symbol name-and-pos)))
      (cond
       ((overlayp position)
        (goto-char (overlay-start position)))
       (t
        (goto-char position)))))
   ((listp symbol-list)
    (dolist (symbol symbol-list)
      (let (name position)
        (cond
         ((and (listp symbol) (imenu--subalist-p symbol))
          (ido-goto-symbol symbol))
         ((listp symbol)
          (setq name (car symbol))
          (setq position (cdr symbol)))
         ((stringp symbol)
          (setq name symbol)
          (setq position
                (get-text-property 1 'org-imenu-marker symbol))))
        (unless (or (null position) (null name)
                    (string= (car imenu--rescan-item) name))
          (add-to-list 'symbol-names name)
          (add-to-list 'name-and-pos (cons name position))))))))


;; Programable setting ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(server-start)
(add-to-list 'load-path "~/.emacs.d/site-lisp")

;;;; chrome
(let ((chrome-bin "/usr/bin/google-chrome"))
  (when (file-exists-p chrome-bin)
    (setq browse-url-browser-function 'browse-url-generic)
    (setq browse-url-generic-program chrome-bin)))

;;(my-add-exec-path "~/apps/UnxUtils/usr/local/wbin")

;; Dired ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook 'dired-load-hook
          (lambda () (load "dired-x")))
(autoload 'wdired-change-to-wdired-mode "wdired")

;; Plugins ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; magit
(autoload 'magit-status "magit" "" t)

;;;; auto-install
(when (require 'auto-install nil t)
  (add-to-list 'load-path auto-install-directory))

;;;; hippie-expand-tab
(require 'hippie-exp-tab nil t)

;;;; japanese-holidays
;;;; (http://www.meadowy.org/meadow/netinstall/export/799/branches/3.00/pkginfo/japanese-holidays/japanese-holidays.el)
(add-hook 'calendar-load-hook
          (lambda ()
            (when (require 'japanese-holidays nil t)
              (setq calendar-holidays
                    (append japanese-holidays local-holidays other-holidays))
              (setq mark-holidays-in-calendar t))))

;; Key-bind ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Repeat

;;(add-hook 'pre-command-hook 'my-repeater)
;;(byte-compile 'my-repeater)
(global-set-key "." 'my-repeat-or-period)
(define-key isearch-mode-map "." 'my-repeat-or-period)

;;;; Useful function
(define-key isearch-mode-map (kbd "C-l") 'my-isearch-yank-symbol)
(global-set-key (kbd "C-c m") 'execute-extended-command)
(global-set-key (kbd "C-w") 'my-kill-word-or-region)
(global-set-key (kbd "C-c i") 'ido-goto-symbol)

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
 '(eshell-cmpl-ignore-case t)
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
 '(ido-mode (quote both) nil (ido))
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
 '(trailing-whitespace ((((class color) (background light)) (:background "linen")))))

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
                      'japanese-jisx0213-1
                      `(,(cadr fonts) . "unicode-bmp"))
    ;; halfwidth katakana
    (set-fontset-font (frame-parameter nil 'font)
                      'katakana-jisx0201
                      `(,(cadr fonts) . "unicode-bmp"))))

