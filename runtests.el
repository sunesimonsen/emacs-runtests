;;; runtests.el --- Run unit tests from Emacs
;;
;; Copyright 2014 Sune Simonsen
;;
;; Author: Sune Simonsen <sune@we-knowhow.dk>
;; URL: https://github.com/sunesimonsen/emacs-runtests
;; Keywords: test
;; Version: 1.0.0
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

(defvar runtests--mode-line-color (face-background 'mode-line))

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
             (goto-char (point-min))
             (compilation-mode)
             (compilation-next-error 1)
             (runtests--color-modeline "Red"))))))

(defgroup runtests nil
  "Emacs extension that will run an external script called.
If the script fails the output of the script will be shown with ansi colors.")

(defcustom runtests-command "runtests"
  "The shell command that will be executed when calling runtests"
  :group 'runtests
  :type '(string :tag "command"))

;;;###autoload
(defun runtests ()
  "Runs all the tests in the current buffer"
  (interactive)
  (when (get-buffer "*runtests*")
    (kill-buffer "*runtests*"))
  (let ((process (start-process "runtests-process" "*runtests*" runtests-command (buffer-file-name))))
    (set-process-filter process 'runtests-ansi-color-filter)
    (set-process-sentinel process 'runtests-sentinel)))

(provide 'runtests)
;;; runtests.el ends here
