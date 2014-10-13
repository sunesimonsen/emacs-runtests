(require 'ansi-color)

(defun runtests ()
  "Runs all the tests in the current buffer"
  (interactive)
  (let* (command result)
    (setq command (concat "runtests " (buffer-name)))
    (setq output
          (replace-regexp-in-string "\033\\[\\(38\\|48\\);5;[0-9]+m" ""
                                    (shell-command-to-string command)))
    (message output)
    (when (get-buffer "*runtests*")
      (kill-buffer "*runtests*"))
    (if (string-match "failing" output)
        (progn
          (runtests--color-modeline "Red")
          (with-current-buffer (get-buffer-create "*runtests*")
            (insert output)
            (runtests--color-buffer))
          (switch-to-buffer "*runtests*"))
      (runtests--color-modeline "Green"))))

(defun runtests--color-modeline (color)
  "Colors the modeline, green success red failure"
  (run-at-time "1 sec" nil 'runtests--reset-color-modeline (face-background 'mode-line))
  (set-face-background 'mode-line color))

(defun runtests--reset-color-modeline (color)
  (set-face-background 'mode-line color))

(defun runtests--color-buffer ()
  (interactive)
  (ansi-color-apply-on-region (point-min) (point-max)))
