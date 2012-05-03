(eval-when-compile
  (require 'cl)
  (require 'hippie-exp))

(defface hetab-face
  '((t (:inherit shadow :underline t)))
  "The face of 'hippie-expand' completion.")

(defvar hetab-overlay (make-overlay 0 0 nil t t))
(delete-overlay hetab-overlay)
(defvar hetab-face 'hetab-face)
(defvar hetab-not-found nil)
(defvar hetab-timer nil)
(defvar hetab-delay-time 0.2)
(defvar hetab-key (kbd "TAB"))

(defun hetab-handle-tab (&optional arg)
  (interactive)
  (require 'hippie-exp)
  (if (hetab-disable-p)
      (indent-for-tab-command arg)
    (hippie-expand arg)))

(defun hetab-disable-p ()
  (or (use-region-p)
      (string-match "[ \t\n]" (string (char-before)))
      (minibufferp (current-buffer))))

(defun hetab-get-completion ()
  (interactive)
  (setq he-tried-table nil)
  (let ((result))
    (flet ((he-substitute-string
            (str &optional trans-case)
            (setq result
                  (if trans-case
                      (he-transfer-case he-search-string str)
                    str))))
      (block nil
        (dolist (func hippie-expand-try-functions-list)
          (if (funcall func nil)
              (return))))
      result)))

(defun hetab-show-phantom ()
  (when (and (eq (key-binding hetab-key) 'hetab-handle-tab)
             (not (or hetab-not-found
                      (hetab-disable-p))))
    (let ((expand-string (hetab-get-completion)))
      (if (not expand-string)
          (setq hetab-not-found (not (eq (marker-position he-string-beg) (point))))
        (let ((buffer-undo-list t))
          (save-excursion (insert "@")))
        (move-overlay hetab-overlay (point) (1+ (point)))
        (overlay-put hetab-overlay 'display
                     (propertize (substring expand-string
                                            (- he-string-end he-string-beg))
                                 'face hetab-face))))))

(defun hetab-set-timer ()
  (unless buffer-read-only
    (when hetab-timer
      (cancel-timer hetab-timer)
      (setq hetab-timer nil))
    (when (overlay-buffer hetab-overlay)
      (let ((buffer-undo-list t))
        (delete-char 1))
      (delete-overlay hetab-overlay))
    (if (and (eq this-command 'self-insert-command)
             (eolp)
             (not (eq last-command-event ? )))
        (setq hetab-timer (run-with-idle-timer hetab-delay-time nil 'hetab-show-phantom))
      (setq hetab-not-found nil))))

(global-set-key hetab-key 'hetab-handle-tab)
(add-hook 'pre-command-hook 'hetab-set-timer)
(provide 'hippie-exp-tab)
