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

(setq runtests--mode-line-color (face-background 'mode-line))

(defun runtests--color-modeline (color)
  "Colors the modeline, green success red failure"
  (run-at-time "1 sec" nil 'set-face-background 'mode-line runtests--mode-line-color)
  (set-face-background 'mode-line color))

(defun runtests-ansi-color-filter (process output)
  (when (buffer-live-p (process-buffer process))
    (with-current-buffer (process-buffer process)
      (let ((moving (= (point) (process-mark process))))
        (save-excursion
          ;; Insert the text, advancing the process marker.
          (goto-char (process-mark process))
          (insert (replace-regexp-in-string "\033\\[\\(38\\|48\\);5;[0-9]+m" "" output))
          (ansi-color-apply-on-region (process-mark process) (point))
          (set-marker (process-mark process) (point)))
        (if moving (goto-char (process-mark process)))))))

(defun runtests-sentinel (process-name event)
  (let ((buffer (process-buffer (get-process process-name))))
    (cond ((string= "finished\n" event)
           (when buffer (kill-buffer buffer))
           (runtests--color-modeline "Green"))
          (t
           (when buffer
             (switch-to-buffer buffer)
             (read-only-mode 't)
             (runtests--color-modeline "Red"))))))

(defun runtests ()
  "Runs all the tests in the current buffer"
  (interactive)
  (when (get-buffer "*runtests*")
    (kill-buffer "*runtests*"))
  (let ((process (start-process "runtests-process" "*runtests*" "runtests" (buffer-file-name))))
    (set-process-filter process 'runtests-ansi-color-filter)
    (set-process-sentinel process 'runtests-sentinel)))

(provide 'runtests)
