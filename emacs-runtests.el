;;; emacs-runtests.el --- Run unit tests from Emacs
;;
;; Copyright 2014 Sune Simonsen
;;
;; Author: Sune Simonsen <sune@we-knowhow.dk>
;; URL: https://github.com/sunesimonsen/emacs-runtests
;; Keywords: test
;; Version: DEV
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2 of
;; the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be
;; useful, but WITHOUT ANY WARRANTY; without even the implied
;; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
;; PURPOSE.  See the GNU General Public License for more details.

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
  (ansi-color-apply-on-region (point-min) (point-max)))

(provide 'runtests)
