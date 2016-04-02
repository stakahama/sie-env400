;;; -*- lexical-binding: t -*-

;; -----------------------------------------------------------------------------
;;
;; rmd-mode for use with emacs
;; Simple functions for emulating basic keybindings (view and compile)
;;    in aucTeX for R markdown.
;; Uses emacs polymode. https://github.com/vspinu/polymode
;; It is possible to set weave functions ("knitR" and "knitR-ESS") in polymode 
;;    but this uses rmarkdown::render().
;;
;; If pandoc is not installed separately, add through RStudio:
;;   Mac: export PATH=$PATH:/Applications/RStudio.app/Contents/MacOS/pandoc
;;   Windows: "c:\Program Files\RStudio\bin\pandoc"
;; as described by http://kbroman.org/knitr_knutshell/pages/Rmarkdown.html
;;
;; -----------------------------------------------------------------------------

;; -----------------------------------------------------------------------------
;; functions

;; use setq rather than defvar for lexical scope
(setq rmd-render-output-buffer "*Rmd render Output*")

(defun rmd-view ()
  "View html output."
  ;; only tested on OS X  
  (interactive)
  (let ((app (cond
	      ((string-equal system-type "windows-nt") "start") 
	      ((string-equal system-type "darwin") "open")
	      ((string-equal system-type "gnu/linux") "xdg-open"))))
    (start-process
     "rmd-view" "*Messages*"
     app (concat (file-name-sans-extension (buffer-file-name)) ".html"))))

(defun rmd-render-sentinel (process event)
  "Print message in minibuffer when there is a change in process status."
   (princ
    (format "Process: %s had the event \"%s\"" process
	    (replace-regexp-in-string "\r?\n\\'" "" event))))

(defun rmd-render-on-buffer-file ()
  "Run .Rmd file of buffer through rmarkdown::render()."
  (interactive)
  (let ((process (start-process
		  "rmd-render" rmd-render-output-buffer
		  "R" "-e" (format "rmarkdown::render('%s')" (buffer-file-name)))))
    (set-process-sentinel process 'rmd-render-sentinel)))

(defun rmd-render-display-output-buffer ()
  (interactive)
  (display-buffer rmd-render-output-buffer))

;; -----------------------------------------------------------------------------
;; keybindings

(defvar rmd-minor-mode-map (make-sparse-keymap))
;; similar to auxtex operations
(define-key rmd-minor-mode-map (kbd "C-c C-c") 'rmd-render-on-buffer-file)
(define-key rmd-minor-mode-map (kbd "C-c C-v") 'rmd-view)
(define-key rmd-minor-mode-map (kbd "C-c C-l") 'rmd-render-display-output-buffer)

;; -----------------------------------------------------------------------------
;; define major and minor modes

;; major mode is defined by poly-markdown+r
;; personal keybindings added as minor mode

(define-minor-mode rmd-minor-mode
  "Provides separate keymap for rmd mode."
  nil nil rmd-minor-mode-map)

(defun rmd-mode ()
  "ESS Markdown mode for rmd files."
  (interactive)
  (require 'poly-R)
  (require 'poly-markdown)
  (let (value)
    (setq value (poly-markdown+r-mode)) ; true/false
    (rmd-minor-mode)                    ; comes after invoking major mode
    value))

;; --------------------------------------------------------------------------
;; auto load modes with .Rmd extension

(add-to-list 'auto-mode-alist '("\\.Rmd\\'" . rmd-mode))
