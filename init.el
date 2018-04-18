;; ###### SETUP PACKAGE MGMT

(require 'package)

(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)
(add-to-list 'package-archives
             '("melpa-stable" . "http://stable.melpa.org/packages/") t)

(package-initialize)

(when (not package-archive-contents)
  (package-refresh-contents))

(when (not (package-installed-p 'better-defaults))
    (package-install 'better-defaults))
(require 'better-defaults)

;; ###### END - SETUP PACKAGE MGMT


;; ###### ACE JUMP MODE
(require 'ace-jump-mode)
(global-set-key (kbd "C-o") 'ace-jump-mode)
(global-set-key (kbd  "C-x p") 'ace-jump-mode-pop-mark)
;; ###### END - ACE JUMP MODE

;; ###### AUTO COMPLETE MODE
(require 'popup)
(require 'auto-complete)
(require 'auto-complete-config)
(ac-config-default)
(ac-flyspell-workaround)

(global-auto-complete-mode t)
(setq ac-auto-show-menu t)
(setq ac-dwim t)
(setq ac-use-menu-map t)
(setq ac-quick-help-delay 1)
(setq ac-quick-help-height 60)
(setq ac-disable-inline t)
(setq ac-show-menu-immediately-on-auto-complete t)
(setq ac-auto-start 2)
(setq ac-candidate-menu-min 0)

(set-default 'ac-sources
             '(ac-source-dictionary
               ac-source-words-in-buffer
               ac-source-words-in-same-mode-buffers
               ac-source-semantic
               ac-source-yasnippet))

(dolist (mode '(magit-log-edit-mode log-edit-mode org-mode text-mode haml-mode
                sass-mode yaml-mode csv-mode espresso-mode haskell-mode
                html-mode nxml-mode sh-mode smarty-mode clojure-mode
                lisp-mode textile-mode markdown-mode tuareg-mode))
  (add-to-list 'ac-modes mode))

(define-key ac-completing-map (kbd "C-M-n") 'ac-next)
(define-key ac-completing-map (kbd "C-M-p") 'ac-previous)
(define-key ac-completing-map "\t" 'ac-complete)
(define-key ac-completing-map (kbd "M-RET") 'ac-help)
(define-key ac-completing-map "\r" 'nil)
;; ###### END - AUTO COMPLETE MODE

;; ###### AUTO HIGHLIGHT SYMBOL
(defvar auto-highlight-symbol-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "M-J") 'ahs-backward)
    (define-key map (kbd "M-K"   ) 'ahs-forward)
    (define-key map (kbd "M-S-<left>"  ) 'ahs-backward-definition )
    (define-key map (kbd "M-S-<right>" ) 'ahs-forward-definition  )
    (define-key map (kbd "M--"         ) 'ahs-back-to-start       )
    (define-key map (kbd "C-x C-'"     ) 'ahs-change-range        )
    (define-key map (kbd "C-x C-a"     ) 'ahs-edit-mode           )
    map))

(require 'auto-highlight-symbol)
(require 'clojure-mode)

(global-auto-highlight-symbol-mode t)
(add-to-list 'ahs-modes 'clojure-mode)
(setq ahs-default-range 'ahs-range-whole-buffer)

;; add support for matching '<' and '>' in clojure mode
(setq ahs-include '((clojure-mode . "^[<>0-9A-Za-z/_.,:;*+=&%|$#@!^?-]+$")))
;; ###### END - AUTO HIGHLIGHT SYMBOL

;; store all backup and autosave files in the tmp dir
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))


;; ###### CIDER
(require 'cider)
(require 'cider-apropos)
(require 'cider-macroexpansion)
(require 'cider-repl)
(require 'cider-mode)

(add-hook 'cider-repl-mode-hook
          (lambda ()
            (eldoc-mode 1)
            (paredit-mode 1)))

(add-hook 'cider-mode-hook
           (lambda ()
             (eldoc-mode 1)
             (paredit-mode 1)))

(setq cider-popup-stacktraces t)
(setq cider-popup-stacktraces-in-repl t)
(add-to-list 'same-window-buffer-names "*cider*")

;;Auto Complete
(require 'ac-cider )

(add-hook 'cider-mode-hook 'ac-cider-setup)
(add-hook 'cider-repl-mode-hook 'ac-cider-setup)

(eval-after-load "auto-complete"
  '(add-to-list 'ac-modes 'cider-mode))

;; Specify the print length to be 100 to stop infinite sequences killing
;; things. This might be dangerous for some people relying on
;; *print-length* being larger. Consider a work around
(defun live-nrepl-set-print-length ()
  (nrepl-send-string-sync "(set! *print-length* 100)" "clojure.core"))

(add-hook 'nrepl-connected-hook 'live-nrepl-set-print-length)

(setq nrepl-port "4555")

;; Show documentation/information with M-RET
(define-key cider-repl-mode-map (kbd "M-RET") 'cider-doc)
(define-key cider-mode-map (kbd "M-RET") 'cider-doc)

(define-key cider-repl-mode-map (kbd "C-c C-l") 'cider-repl-clear-buffer)
(define-key cider-repl-mode-map (kbd "C-x C-x C-x") 'cider-make-connection-default)

;; https://github.com/clojure-emacs/cider#basic-configuration
(setq cider-auto-select-error-buffer nil)

;; ###### END - CIDER

;; ###### CLOJURE MODE
(eval-after-load 'find-file-in-project
  '(add-to-list 'ffip-patterns "*.clj"))

(require 'clojure-mode)

(add-hook 'clojure-mode-hook
          (lambda ()
            (setq buffer-save-without-query t)))

;;Treat hyphens as a word character when transposing words
(defvar clojure-mode-with-hyphens-as-word-sep-syntax-table
  (let ((st (make-syntax-table clojure-mode-syntax-table)))
    (modify-syntax-entry ?- "w" st)
    st))

(defun live-transpose-words-with-hyphens (arg)
  "Treat hyphens as a word character when transposing words"
  (interactive "*p")
  (with-syntax-table clojure-mode-with-hyphens-as-word-sep-syntax-table
    (transpose-words arg)))

(define-key clojure-mode-map (kbd "M-t") 'live-transpose-words-with-hyphens)

(setq auto-mode-alist (append '(("\\.cljs$" . clojurescript-mode))
                              auto-mode-alist))

(dolist (x '(scheme emacs-lisp lisp clojure))
  (add-hook (intern (concat (symbol-name x) "-mode-hook")) 'enable-paredit-mode)
  (add-hook (intern (concat (symbol-name x) "-mode-hook")) 'rainbow-delimiters-mode))

(defun live-warn-when-cider-not-connected ()
      (interactive)
      (message "nREPL server not connected. Run M-x cider or M-x cider-jack-in to connect."))

(define-key clojure-mode-map (kbd "C-M-x")   'live-warn-when-cider-not-connected)
(define-key clojure-mode-map (kbd "C-x C-e") 'live-warn-when-cider-not-connected)
(define-key clojure-mode-map (kbd "C-c C-e") 'live-warn-when-cider-not-connected)
(define-key clojure-mode-map (kbd "C-c C-l") 'live-warn-when-cider-not-connected)
(define-key clojure-mode-map (kbd "C-c C-r") 'live-warn-when-cider-not-connected)

(cider-enable-on-existing-clojure-buffers)
;; ###### END - CLOJURE MODE

;; ###### COLOR THEME
(load-file (concat user-emacs-directory "themes/cyberpunk.el"))
(load-file (concat user-emacs-directory "themes/gandalf.el"))
(color-theme-cyberpunk)
(set-cursor-color "yellow")
;; ###### END - COLOR THEME

;; ###### RECENTF
(require 'recentf)

;; enable recent files mode.
(recentf-mode t)

;; 50 files ought to be enough.
(setq recentf-max-saved-items 50)

(defun ido-recentf-open ()
  "Use `ido-completing-read' to \\[find-file] a recent file"
  (interactive)
  (if (find-file (ido-completing-read "Find recent file: " recentf-list))
      (message "Opening file...")
        (message "Aborting")))

(global-set-key (kbd "C-x C-r") 'ido-recentf-open)
;; ###### END - RECENTF

;; ###### IDOMENU
(require 'idomenu)
(require 'flx-ido)

(ido-mode 1)
(flx-ido-mode 1)
(setq ido-enable-prefix nil
      ido-create-new-buffer 'always
      ido-max-prospects 10
      ido-default-file-method 'selected-window
      ido-everywhere 1)

(icomplete-mode 1)

(defvar live-symbol-names)
(defvar live-name-and-pos)

(defun live-recentf-ido-find-file ()
  "Find a recent file using ido."
  (interactive)
  (let ((file (ido-completing-read "Choose recent file: " recentf-list nil t)))
    (when file
      (find-file file))))

(defun live-ido-goto-symbol (&optional symbol-list)
      "Refresh imenu and jump to a place in the buffer using Ido."
      (interactive)
      (unless (featurep 'imenu)
        (require 'imenu nil t))
      (cond
       ((not symbol-list)
        (let ((ido-mode ido-mode)
              (ido-enable-flex-matching
               (if (boundp 'ido-enable-flex-matching)
                   ido-enable-flex-matching t))
              live-name-and-pos live-symbol-names position selected-symbol)
          (unless ido-mode
            (ido-mode 1)
            (setq ido-enable-flex-matching t))
          (while (progn
                   (imenu--cleanup)
                   (setq imenu--index-alist nil)
                   (live-ido-goto-symbol (imenu--make-index-alist))
                   (setq selected-symbol
                         (ido-completing-read "Symbol? " live-symbol-names))
                   (string= (car imenu--rescan-item) selected-symbol)))
          (unless (and (boundp 'mark-active) mark-active)
            (push-mark nil t nil))
          (setq position (cdr (assoc selected-symbol live-name-and-pos)))
          (cond
           ((overlayp position)
            (goto-char (overlay-start position)))
           (t
            (goto-char position)))))
       ((listp symbol-list)
        (dolist (symbol symbol-list)
          (let (name position)
            (cond
             ((and (listp symbol) (imenu--subalist-p symbol))
              (live-ido-goto-symbol symbol))
             ((listp symbol)
              (setq name (car symbol))
              (setq position (cdr symbol)))
             ((stringp symbol)
              (setq name symbol)
              (setq position
                    (get-text-property 1 'org-imenu-marker symbol))))
            (unless (or (null position) (null name)
                        (string= (car imenu--rescan-item) name))
              (add-to-list 'live-symbol-names name)
              (add-to-list 'live-name-and-pos (cons name position))))))))

;; JUMP TO a definition in the current file.
(global-set-key (kbd "C-x C-i") 'live-ido-goto-symbol)
(global-set-key (kbd "C-x f") 'live-recentf-ido-find-file)
;; ###### END - IDOMENU

;; ###### LISP MODE
(add-to-list 'auto-mode-alist '("\\.el$" . emacs-lisp-mode))
(add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)
(add-hook 'lisp-interaction-mode-hook 'turn-on-eldoc-mode)
(add-hook 'ielm-mode-hook 'turn-on-eldoc-mode)

(define-key lisp-mode-shared-map (kbd "RET") 'reindent-then-newline-and-indent)

(defun live-lisp-describe-thing-at-point ()
  "Show the documentation of the Elisp function and variable near point.
   This checks in turn:
     -- for a function name where point is
     -- for a variable name where point is
     -- for a surrounding function call"
          (interactive)
          (let (sym)
            ;; sigh, function-at-point is too clever.  we want only the first half.
            (cond ((setq sym (ignore-errors
                               (with-syntax-table emacs-lisp-mode-syntax-table
                                 (save-excursion
                                   (or (not (zerop (skip-syntax-backward "_w")))
                                       (eq (char-syntax (char-after (point))) ?w)
                                       (eq (char-syntax (char-after (point))) ?_)
                                       (forward-sexp -1))
                                   (skip-chars-forward "`'")
                                   (let ((obj (read (current-buffer))))
                                     (and (symbolp obj) (fboundp obj) obj))))))
                   (describe-function sym))
                  ((setq sym (variable-at-point)) (describe-variable sym)))))


(defun live-lisp-top-level-p ()
  "Returns true if point is not within a given form i.e. it's in
  toplevel 'whitespace'. Only works for lisp modes."
  (= 0 (car (syntax-ppss))))

(defun live-check-lisp-top-level-p ()
  "Returns true if point is not within a given form i.e. it's in
  toplevel 'whitespace'. Only works for lisp modes."
  (interactive)
  (if (live-lisp-top-level-p)
      (message "top level")
    (message "not top level")))

(defun live-whitespace-at-point-p ()
  "Returns true if the char at point is whitespace"
  (string-match "[ \n\t]" (buffer-substring (point) (+ 1 (point)))))

(require 'elisp-slime-nav)
(dolist (hook '(emacs-lisp-mode-hook ielm-mode-hook))
  (add-hook hook 'turn-on-elisp-slime-nav-mode))

(global-set-key (kbd "C-c m s") 'eval-and-replace) ;swap
(global-set-key (kbd "C-c m b") 'eval-buffer)
(global-set-key (kbd "C-c m e") 'eval-last-sexp)
(global-set-key (kbd "C-c m i") 'eval-expression)
(global-set-key (kbd "C-c m d") 'eval-defun)
(global-set-key (kbd "C-c m n") 'eval-print-last-sexp)
(global-set-key (kbd "C-c m r") 'eval-region)
(define-key lisp-mode-shared-map (kbd "M-RET") 'live-lisp-describe-thing-at-point)
;; ###### END - LISP MODE

;; ###### PAREDIT
(eval-after-load 'paredit
  ;; need a binding that works in the terminal
  '(define-key paredit-mode-map (kbd "M-)") 'paredit-forward-slurp-sexp))

(require 'paredit)
(require 'thingatpt)

(defun live-paredit-next-top-level-form ()
  (interactive)
  (while (ignore-errors (paredit-backward-up) t))
  (live-paredit-forward))

(defun live-paredit-previous-top-level-form ()
  (interactive)
  (if (ignore-errors (paredit-backward-up) t)
      (while (ignore-errors (paredit-backward-up) t))
    (paredit-backward)))

(defun live-paredit-forward ()
  "Feels more natural to move to the beginning of the next item
   in the sexp, not the end of the current one."
  (interactive)
  (if (and (not (paredit-in-string-p))
           (save-excursion
             (ignore-errors
               (forward-sexp)
               (forward-sexp)
               t)))
      (progn
        (forward-sexp)
        (forward-sexp)
        (backward-sexp))
    (paredit-forward)))

(defun live-paredit-forward-slurp-sexp-neatly ()
  (interactive)
  (save-excursion
    (cond ((or (paredit-in-comment-p)
               (paredit-in-char-p))
           (error "Invalid context for slurping S-expressions."))
          ((paredit-in-string-p)
           (paredit-forward-slurp-into-string))
          (t

           (save-excursion
             (paredit-forward-up)
             (paredit-backward-down)
             (paredit-forward-slurp-sexp)
             (just-one-space)))))
  (when (not (save-excursion
               (ignore-errors
                 (backward-sexp)
                 t)))
    (delete-horizontal-space)))



(defun live-paredit-forward-kill-sexp (&optional arg)
  (interactive "p")
  (cond ((or (paredit-in-comment-p)
             (paredit-in-string-p)) (kill-word (or arg 1)))
        (t (kill-sexp (or arg 1)))))

(defun live-paredit-backward-kill-sexp (&optional arg)
  (interactive "p")
  (cond ((or (paredit-in-comment-p)
             (paredit-in-string-p)) (backward-kill-word (or arg 1)))
        (t (backward-kill-sexp (or arg 1)))))

(defun live-paredit-backward-kill ()
  (interactive)
  (let ((m (point-marker)))
    (paredit-backward-up)
    (forward-char)
    (delete-region (point) m)))

(defun live-paredit-delete-horizontal-space ()
  (interactive)
  (just-one-space -1)
  (paredit-backward-delete))

(defun live-paredit-tidy-trailing-parens ()
  (interactive)
  (save-excursion
    (while (ignore-errors (paredit-forward-up) t))
    (backward-char)
    (live-paredit-delete-horizontal-space)
    (while
        (or
         (eq (char-before) ?\))
         (eq (char-before) ?\})
         (eq (char-before) ?\]))
      (backward-char)
      (live-paredit-delete-horizontal-space))))

(defun live-paredit-reindent-defun (&optional argument)
  "Reindent the definition that the point is on. If the point is
  in a string or a comment, fill the paragraph instead, and with
  a prefix argument, justify as well. Doesn't mess about with
  Clojure fn arglists when filling-paragraph in docstrings.

  Also tidies up trailing parens when in a lisp form"
  (interactive "P")
  (cond ((paredit-in-comment-p) (fill-paragraph argument))
        ((paredit-in-string-p) (progn
                                 (save-excursion
                                   (paredit-forward-up)
                                   (insert "\n"))
                                 (fill-paragraph argument)
                                 (save-excursion
                                   (paredit-forward-up)
                                   (delete-char 1))))
        (t (when (not (live-paredit-top-level-p))
             (progn (save-excursion
                      (end-of-defun)
                      (beginning-of-defun)
                      (indent-sexp))
                    (live-paredit-tidy-trailing-parens))))))


(defun live-paredit-forward-down ()
  "Doesn't freeze Emacs if attempted to be called at end of
   buffer. Otherwise similar to paredit-forward-down."
  (interactive)
  (if (save-excursion
          (forward-comment (buffer-size))
          (not (live-end-of-buffer-p)))
      (paredit-forward-down)
    (error "unexpected end of buffer")))

(defun live-paredit-top-level-p ()
  "Returns true if point is not within a given form i.e. it's in
  toplevel 'whitespace'"
  (not
   (save-excursion
     (ignore-errors
       (paredit-forward-up)
       t))))

(defun live-paredit-copy-sexp-at-point ()
  (interactive)
    (kill-new (thing-at-point 'sexp)))

(define-key paredit-mode-map (kbd "M-j")     'paredit-join-sexps)
(define-key paredit-mode-map (kbd "M-P")     'live-paredit-previous-top-level-form)
(define-key paredit-mode-map (kbd "M-N")     'live-paredit-next-top-level-form)
(define-key paredit-mode-map (kbd "C-M-f")   'live-paredit-forward)
(define-key paredit-mode-map (kbd "M-q")     'live-paredit-reindent-defun)
(define-key paredit-mode-map (kbd "M-d")     'live-paredit-forward-kill-sexp)
(define-key paredit-mode-map (kbd "M-k")     'live-paredit-backward-kill)
(define-key paredit-mode-map (kbd "M-\\")    'live-paredit-delete-horizontal-space)
(define-key paredit-mode-map (kbd "C-M-i")   'paredit-forward-down)
(define-key paredit-mode-map (kbd "C-M-n")   'paredit-forward-up)
(define-key paredit-mode-map (kbd "C-M-p")   'paredit-backward-down)
(define-key paredit-mode-map (kbd "C-M-u")   'paredit-backward-up)
(define-key paredit-mode-map (kbd "M-T")     'transpose-sexps)
;; ###### END - PAREDIT


;; ###### POPWIN
(require 'popwin)
(setq display-buffer-function 'popwin:display-buffer)

(setq popwin:special-display-config
      '(("*Help*"  :height 30)
        ("*Completions*" :noselect t)
        ("*Messages*" :noselect t :height 30)
        ("*Apropos*" :noselect t :height 30)
        ("*compilation*" :noselect t)
        ("*Backtrace*" :height 30)
        ("*Messages*" :height 30)
        ("*Occur*" :noselect t)
        ("*Ido Completions*" :noselect t :height 30)
        ("*magit-commit*" :noselect t :height 40 :width 80 :stick t)
        ("*magit-diff*" :noselect t :height 40 :width 80)
        ("*magit-edit-log*" :noselect t :height 15 :width 80)
        ("\\*ansi-term\\*.*" :regexp t :height 30)
        ("*shell*" :height 30)
        (".*overtone.log" :regexp t :height 30)
        ("*gists*" :height 30)
        ("*sldb.*":regexp t :height 30)
        ("*cider-error*" :height 30 :stick t)
        ("*cider-doc*" :height 30 :stick t)
        ("*cider-src*" :height 30 :stick t)
        ("*cider-result*" :height 30 :stick t)
        ("*cider-macroexpansion*" :height 30 :stick t)
        ("*Kill Ring*" :height 30)
        ("*Compile-Log*" :height 30 :stick t)
        ("*git-gutter:diff*" :height 30 :stick t)))
;; ###### END - POPWIN

;; ###### RAINBOW DELIMITERS
(require 'rainbow-delimiters)
(set-face-attribute 'rainbow-delimiters-depth-1-face nil :foreground "#BB2222")
(set-face-attribute 'rainbow-delimiters-depth-2-face nil :foreground "#BB7700")
(set-face-attribute 'rainbow-delimiters-depth-3-face nil :foreground "#BBBB22")
(set-face-attribute 'rainbow-delimiters-depth-4-face nil :foreground "#11BB11")
(set-face-attribute 'rainbow-delimiters-depth-5-face nil :foreground "#33BBBB")
(set-face-attribute 'rainbow-delimiters-depth-6-face nil :foreground "#5555AA")
(set-face-attribute 'rainbow-delimiters-depth-7-face nil :foreground "#AA55AA")
(set-face-attribute 'rainbow-delimiters-depth-8-face nil :foreground "#BBBBBB")
(set-face-attribute 'rainbow-delimiters-depth-9-face nil :foreground "#66FF66")
;; ###### END - RAINBOW DELIMITERS

;; ###### SMEX
(require 'smex)
(smex-initialize)
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)
;; This is your old M-x.
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)
;; ###### END - SMEX

;; ###### UNDO TREE
(require 'undo-tree)
(global-undo-tree-mode)
;; ###### END -

;; ###### MISC

;; Activate occur easily inside isearch
(define-key isearch-mode-map (kbd "C-o")
  (lambda () (interactive)
    (let ((case-fold-search isearch-case-fold-search))
      (occur (if isearch-regexp isearch-string (regexp-quote isearch-string))))))


(global-unset-key (kbd "C-z")) ;; get rid of "suspend frame"
(cua-mode 0) ;; kill CUA

(global-linum-mode t)
(setq column-number-mode t)
(defalias 'yes-or-no-p 'y-or-n-p)

(global-set-key (kbd  "C-x x") 'rgrep)

(defun switch-to-most-recent-buffer ()
      (interactive)
      (switch-to-buffer (other-buffer (current-buffer) 1)))
(global-set-key (kbd  "C-M-<return>") 'switch-to-most-recent-buffer)
(global-set-key (kbd  "C-M-<backspace>") 'revert-buffer)

(defun gentle-visible-bell ()
   (invert-face 'mode-line)
   (run-with-timer 0.1 nil 'invert-face 'mode-line))

(setq visible-bell nil
      ring-bell-function #'gentle-visible-bell)

(defun sudo-edit (&optional arg)
  "Edit currently visited file as root. With a prefix ARG prompt
for a file to visit. Will also prompt for a file to visit if
current buffer is not visiting a file."
  (interactive "P")
  (if (or arg (not buffer-file-name))
      (find-file (concat "/sudo:root@localhost:"
                         (ido-read-file-name "Find file(as root): ")))
    (find-alternate-file (concat "/sudo:root@localhost:" buffer-file-name))))

(eval-after-load 'clojure-mode
  '(sayid-setup-package))

(setq inhibit-startup-screen t)

;; ###### END - MISC

(message "\n\n init.el done loading\n\n")
