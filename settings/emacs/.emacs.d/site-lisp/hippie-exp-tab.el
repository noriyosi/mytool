(eval-when-compile (require 'cl))

(require 'hippie-exp)

(defface hetab-face
  '((t (:inherit shadow :underline t)))
  "The face of 'hippie-expand' completion.")

(defvar hetab-overlay (make-overlay 0 0 nil t t))
(defvar hetab-face 'hetab-face)
(defvar hetab-not-found nil)
(defvar hetab-timer nil)
(defvar hetab-delay-time 0.2)
(defvar hetab-marker nil)
(defvar hetab-key (kbd "TAB"))

(defun hetab-handle-tab (&optional arg)
  (interactive)
  (if (hetab-disable-p)
      (indent-for-tab-command arg)
    (hippie-expand arg)))

(defun hetab-disable-p ()
  (or (use-region-p)
      (string-match "[ \t\n]" (string (char-before)))
      ;;(not (string-match "[ \t\n]" (string (char-after))))
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
             (not hetab-not-found)
             (not (hetab-disable-p)))
    (let ((expand-string (hetab-get-completion)))
      (if expand-string
          (let ((string-with-face (propertize (substring expand-string
                                                         (- he-string-end
                                                            he-string-beg))
                                              'face hetab-face)))
            (setq hetab-marker (point-marker))
            (let ((buffer-undo-list t))
              (insert " "))
            (backward-char)
            ;; (let ((end (save-excursion (move-end-of-line 1) (point))))
            ;;   (move-overlay hetab-overlay he-string-end
            ;;                 (min end (+ he-string-end (length string-with-face) 1))))
            (move-overlay hetab-overlay he-string-end (1+ he-string-end))
            (overlay-put hetab-overlay 'display (substring string-with-face 0 1))
            (overlay-put hetab-overlay 'after-string (substring string-with-face 1)))
        (setq hetab-not-found t)))))

(defun hetab-set-timer ()
  (when hetab-timer
    (cancel-timer hetab-timer)
    (setq hetab-timer nil))
  (when hetab-marker
    (with-current-buffer (marker-buffer hetab-marker)
      (save-excursion
        (goto-char hetab-marker)
        (let ((buffer-undo-list t))
          (delete-char 1))))
    (setq hetab-marker nil)
    (delete-overlay hetab-overlay))
  (setq hetab-not-found nil)
  (if (and (eq this-command 'self-insert-command)
           (eolp)
           (not (eq last-command-event ? )))
      (setq hetab-timer (run-with-idle-timer hetab-delay-time nil 'hetab-show-phantom))
    (setq hetab-not-found nil)))

(global-set-key hetab-key 'hetab-handle-tab)
(add-hook 'pre-command-hook 'hetab-set-timer)

(provide 'hippie-exp-tab)
