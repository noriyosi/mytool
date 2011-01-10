(eval-when-compile (require 'cl))

(defface hetab-face
  '((t (:inherit shadow :underline t)))
  "The face of 'hippie-expand' completion.")

(defvar hetab-overlay nil)
(defvar hetab-insert-count 1)
(defvar hetab-count-of-start-show 2)
(defvar hetab-face 'hetab-face)
(defvar hetab-not-found nil)

(defun hetab-handle-tab (&optional arg)
  (interactive)
  (if (or (use-region-p)
          (hetab-before-space-or-bolp))
      (indent-for-tab-command arg)
    (hippie-expand arg)))

(defun hetab-before-space-or-bolp ()
  (use-region-p)
  (string-match "[ \t\n]" (string (char-before))))

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
  (if (overlayp hetab-overlay)
      (delete-overlay hetab-overlay)
    (require 'hippie-exp))
  (if (and (eq this-command 'self-insert-command)
           (eq (key-binding (kbd "TAB")) 'hetab-handle-tab)
           (not hetab-not-found)
           (not (or (minibufferp (current-buffer))
                    (hetab-before-space-or-bolp))))
      (if (<= hetab-count-of-start-show hetab-insert-count)
          (let ((expand-string (hetab-get-completion)))
            (if expand-string
                (let ((string-with-face (propertize (substring expand-string
                                                               (- he-string-end
                                                                  he-string-beg))
                                                    'face hetab-face)))
                  (if (overlayp hetab-overlay)
                      (move-overlay hetab-overlay
                                    he-string-beg he-string-end)
                    (setq hetab-overlay
                          (make-overlay he-string-beg he-string-end nil t t)))
                  (overlay-put hetab-overlay
                               'after-string string-with-face))
              (setq hetab-not-found t)))
        (incf hetab-insert-count))
    (setq hetab-insert-count 1)
    (when (or (not (eq this-command 'self-insert-command))
              (eq last-command-event ? ))
      (setq hetab-not-found nil))))

(global-set-key (kbd "TAB") 'hetab-handle-tab)
(add-hook 'post-command-hook 'hetab-show-phantom)

(provide 'hippie-exp-tab)
