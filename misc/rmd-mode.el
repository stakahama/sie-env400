;; for use with emacs

;; -----------------------------------------------------------------------------
;; functions

(defun rmd-view ()
  (interactive)
  (start-process
   "rmd-view" "*Messages*"
   "open" (concat (file-name-sans-extension (buffer-file-name)) ".html")))

(defun rmd-render-on-buffer-file ()
  (interactive)
  (start-process
   "rmd-render" "*rmd-render output*"
   "R" "-e" (format "rmarkdown::render('%s')" (buffer-file-name))))

;; -----------------------------------------------------------------------------
;; keybindings

(defvar rmd-minor-mode-map (make-sparse-keymap))
(define-key rmd-minor-mode-map (kbd "C-c C-c") 'rmd-render-on-buffer-file)
(define-key rmd-minor-mode-map (kbd "C-c C-v") 'rmd-view)

;; -----------------------------------------------------------------------------
;; define major and minor modes

;; major mode is defined by poly-markdown+r
;; personal keybindings added as minor mode

(defun rmd-mode ()
  "ESS Markdown mode for rmd files"
  (interactive)
  (rmd-minor-mode)  
  (require 'poly-R)
  (require 'poly-markdown)
  (poly-markdown+r-mode))

(define-minor-mode rmd-minor-mode
  "An ad-hoc mode for providing user keymap"
  nil nil rmd-minor-mode-map)

;; --------------------------------------------------------------------------
;; auto load modes with .Rmd extension

(add-to-list 'auto-mode-alist '("\\.Rmd\\'" . rmd-mode))
