;; http://www.bookshelf.jp/pukiwiki/pukiwiki.php?cmd=read&page=Meadow%2F%B5%AF%C6%B0%C2%AE%C5%D9

(defconst my-time-zero (current-time))
(defvar my-time-list nil)

(defun my-time-lag-calc (lag label)
  (if (assoc label my-time-list)
      (setcdr (assoc label my-time-list)
              (- lag (cdr (assoc label my-time-list))))
    (setq my-time-list (cons (cons label lag) my-time-list))))

(defun my-time-lag (label)
  (let* ((now (current-time))
         (min (- (car now) (car my-time-zero)))
         (sec (- (car (cdr now)) (car (cdr my-time-zero))))
         (msec (/ (- (car (cdr (cdr now)))
                     (car (cdr (cdr my-time-zero))))
                  1000))
         (lag (+ (* 60000 min) (* 1000 sec) msec)))
    (my-time-lag-calc lag label)))

(defun my-time-lag-print ()
  (message (prin1-to-string
            (sort my-time-list
                  (lambda  (x y)  (> (cdr x) (cdr y)))))))
(my-time-lag "total")
(add-hook 'after-init-hook
          (lambda () (my-time-lag "total")
            (my-time-lag-print)
            ;;(ad-disable-regexp 'require-time)
            (switch-to-buffer
             (get-buffer "*Messages*"))
            ) t) ;; (2004/01/01 ïœçX)
(defadvice require
  (around require-time activate)
  (my-time-lag (format "require-%s"
                       (ad-get-arg 0)))
  ad-do-it
  (my-time-lag (format "require-%s"
                       (ad-get-arg 0)))
  )

(provide 'speed-meter)

