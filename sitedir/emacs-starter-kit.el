(provide 'emacs-starter-kit)


(defun hi () (interactive) (insert-string "HI\n"))
(global-set-key "\C-c\C-h" 'hi)
