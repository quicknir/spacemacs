;;; funcs.el --- C/C++ Layer functions File for Spacemacs
;;
;; Copyright (c) 2012-2018 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3


;; clang

(defun spacemacs/clang-format-region-or-buffer (&optional style)
  "Format the current region or buffer with clang-format according to STYLE."
  (interactive)
  (save-excursion
    (if (region-active-p)
        (progn
          (clang-format-region (region-beginning) (region-end) style)
          (message "Formatted region"))
      (progn
        (clang-format-buffer style)
        (message "Formatted buffer %s" (buffer-name))))))

(defun spacemacs//clang-format-on-save ()
  "Format the current buffer with clang-format on save when
`c-c++-enable-clang-format-on-save' is non-nil."
  (when c-c++-enable-clang-format-on-save
    (spacemacs/clang-format-region-or-buffer)))

(defun spacemacs/clang-format-on-save ()
  "Add before-save hook for clang-format."
  (add-hook 'before-save-hook 'spacemacs//clang-format-on-save nil t))


;; realgud

(defun spacemacs//short-key-state (modeon)
  "Set evil-evilified-state explicitly."
  (if modeon
      (evil-evilified-state)
    (evil-normal-state)))


;; rtags

(defun spacemacs/c-c++-use-rtags (&optional useFileManager)
  "Return non-nil if rtags function should be used."
  ;; this function is used to fallback on gtags function if rtags is not
  ;; supported. So if gtags layer is not used we disable the fallback by
  ;; returning always t.
  (or (not (configuration-layer/layer-used-p 'gtags))
      (and (rtags-executable-find "rc")
           (cond ((not (gtags-get-rootpath)) t)
                 ((and (not (eq major-mode 'c++-mode))
                       (not (eq major-mode 'c-mode))) (rtags-has-filemanager))
                 (useFileManager (rtags-has-filemanager))
                 (t (rtags-is-indexed))))))

(defun spacemacs/c-c++-tags-find-symbol-at-point (&optional prefix)
  (interactive "P")
  (if (and (not (rtags-find-symbol-at-point prefix))
           rtags-last-request-not-indexed)
      (gtags-find-tag)))

(defun spacemacs/c-c++-tags-find-references-at-point (&optional prefix)
  (interactive "P")
  (if (and (not (rtags-find-references-at-point prefix))
           rtags-last-request-not-indexed)
      (gtags-find-rtag)))

(defun spacemacs/c-c++-tags-find-symbol ()
  (interactive)
  (call-interactively (if (spacemacs/c-c++-use-rtags)
                          'rtags-find-symbol 'gtags-find-symbol)))

(defun spacemacs/c-c++-tags-find-references ()
  (interactive)
  (call-interactively (if (spacemacs/c-c++-use-rtags)
                          'rtags-find-references 'gtags-find-rtag)))

(defun spacemacs/c-c++-tags-find-file ()
  (interactive)
  (call-interactively (if (spacemacs/c-c++-use-rtags t)
                          'rtags-find-file 'gtags-find-file)))

(defun spacemacs/c-c++-tags-imenu ()
  (interactive)
  (call-interactively (if (spacemacs/c-c++-use-rtags t)
                          'rtags-imenu 'idomenu)))
