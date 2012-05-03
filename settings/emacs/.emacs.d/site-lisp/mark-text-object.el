;;; mark-text-object.el -- Mark vim-like text object.

;; Copyright (C) 2012 noriyosi.

;; Author: noriyosi
;; Version: 0.0.1
;; Keywords: tools

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;(eval-when-compile (require 'cl))

(defvar mark-text-object-marker '(("[" . "]") ("(" . ")") ("<" . ">")
                                   ("{" . "}") ("\"" . "\"") ("'" . "'")
                                   ("`" . "`"))
  "Markers are used for boundary of text object. Use it in regexp.
So markers must be escaped and '[' must be first.")

(defvar mark-text-object-enable-binding nil)

(defun mark-text-object-get-beginnings-regexp ()
  (concat "[" (apply 'concat (mapcar 'car mark-text-object-marker)) "]"))

(defun mark-text-object-get-ends-regexp ()
  (concat "[" (apply 'concat (mapcar 'cdr mark-text-object-marker)) "]"))

(defun mark-text-object-search-pair-point ()
  (let* ((end-char (char-to-string (char-before)))
         (start-char (car (rassoc end-char mark-text-object-marker)))
         (regexp (concat "[" end-char start-char "]"))
         (found-point))
    (save-excursion
      (if (string-equal start-char end-char)
          (let ((right (point))
                (left)
                (bound (save-excursion (move-end-of-line 1) (point))))
            (move-beginning-of-line 1)
            (let ((searching t))
              (while searching
                (setq left (search-forward start-char bound t))
                (if (search-forward start-char bound t)
                    (when (or (and (= right (point))
                                   (goto-char (- left 1)))
                              (= left right))
                      (setq found-point (point))
                      (setq searching nil))
                  (setq searching nil)))))
        (let ((count 1)
              (searching t))
          (backward-char)
          (while searching
            (if (search-backward-regexp regexp nil t)
                (if (string-equal (char-to-string (char-after))
                                  start-char)
                    (when (= (setq count (1- count)) 0)
                      (setq searching nil)
                      (setq found-point (point)))
                  (setq count (1+ count)))
              (setq searching nil))))))
    (when found-point
      (goto-char found-point))))

(defun mark-text-object-block (&optional include)
  (interactive "P")
  (let ((start)
        (end))
    (save-excursion
      (let ((origin (point))
            (end-point (point))
            (searching t))
        (while searching
          (setq searching
                (search-forward-regexp (mark-text-object-get-ends-regexp) nil t))
          (when searching
            (setq end-point (point))
            (let ((found (mark-text-object-search-pair-point)))
              (when found
                (when (or (when (= (1- end-point) origin)
                            (when (< origin found)
                              ;; If matching when beginning-char same as
                              ;; end-char and left side is on cursor,
                              ;; 'end-point is used for left-side.
                              ;; So decrement point to include char on cursor.
                              (setq end-point (1- end-point)))
                            t)
                          (<= found origin))
                  (setq start (min (point) end-point))
                  (setq end (max (point) end-point))
                  (setq searching nil))))
            (goto-char end-point)))))
    (when start
      (goto-char (+ start (if include 0 1)))
      (set-mark (- end (if include 0 1))))))

(defun mark-text-object-word ()
  (interactive)
  (let ((location (bounds-of-thing-at-point 'symbol)))
    (goto-char (car location))
    (set-mark (cdr location))))

(defun mark-text-object-use-char-interactive ()
  (list (read-char (concat "Select boundary -- "
                           (mapconcat 'car mark-text-object-marker ", ")
                           ", "
                           (mapconcat 'cdr mark-text-object-marker ", ")
                           ": "))))

(defun mark-text-object-block-use-char (char)
  (interactive (mark-text-object-use-char-interactive))
  (let* ((str (char-to-string char))
         (marker (or (assoc str mark-text-object-marker)
                     (rassoc str mark-text-object-marker))))
    (let ((mark-text-object-marker (list marker)))
      (mark-text-object-block current-prefix-arg))))

(provide 'mark-text-object)

