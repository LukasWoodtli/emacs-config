;;;;
;; Packages
;;;;

;; Define package repositories
(require 'package)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/") t)
(add-to-list 'package-archives
             '("tromey" . "http://tromey.com/elpa/") t)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)

(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))

;; (setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
;;                          ("marmalade" . "http://marmalade-repo.org/packages/")
;;                          ("melpa" . "http://melpa-stable.milkbox.net/packages/")))


;; Load and activate emacs packages. Do this first so that the
;; packages are loaded before you start trying to modify them.
;; This also sets the load path.
(package-initialize)

;; Download the ELPA archive description if needed.
;; This informs Emacs about the latest versions of all packages, and
;; makes them available for download.
(when (not package-archive-contents)
  (package-refresh-contents))

;; The packages you want installed. You can also install these
;; manually with M-x package-install
;; Add in your own as you wish:
(defvar my-packages
  '(;; makes handling lisp expressions much, much easier
    ;; Cheatsheet: http://www.emacswiki.org/emacs/PareditCheatsheet
    paredit

    ;; key bindings and code colorization for Clojure
    ;; https://github.com/clojure-emacs/clojure-mode
    clojure-mode

    ;; extra syntax highlighting for clojure
    clojure-mode-extra-font-locking

    ;; integration with a Clojure REPL
    ;; https://github.com/clojure-emacs/cider
    cider

    ;; allow ido usage in as many contexts as possible. see
    ;; customizations/better-defaults.el line 47 for a description
    ;; of ido
    ido-ubiquitous

    ;; Enhances M-x to allow easier execution of commands. Provides
    ;; a filterable list of possible commands in the minibuffer
    ;; http://www.emacswiki.org/emacs/Smex
    smex

    ;; project navigation
    projectile

    ;; colorful parenthesis matching
    rainbow-delimiters

    ;; edit html tags like sexps
    tagedit

    ;; git integration
    magit

    ;; Markdown
    markdown-mode

    ;; Spell checking
    flyspell
    
    ;; Oberon major mode
    oberon
    ))


;; On OS X, an Emacs instance started from the graphical user
;; interface will have a different environment than a shell in a
;; terminal window, because OS X does not run a shell during the
;; login. Obviously this will lead to unexpected results when
;; calling external utilities like make from Emacs.
;; This library works around this problem by copying important
;; environment variables from the user's shell.
;; https://github.com/purcell/exec-path-from-shell
(if (eq system-type 'darwin)
    (add-to-list 'my-packages 'exec-path-from-shell))

(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)))



;; Place downloaded elisp files in ~/.emacs.d/vendor. You'll then be able
;; to load them.
;;
;; For example, if you download yaml-mode.el to ~/.emacs.d/vendor,
;; then you can add the following code to this file:
;;
;; (require 'yaml-mode)
;; (add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
;; 
;; Adding this code will make Emacs enter yaml mode whenever you open
;; a .yml file
(add-to-list 'load-path "~/.emacs.d/vendor")

;; File association
;; setup files ending in “.js” to open in js2-mode
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

;;;;
;; Customization
;;;;

;; Add a directory to our load path so that when you `load` things
;; below, Emacs knows where to look for the corresponding file.
(add-to-list 'load-path "~/.emacs.d/customizations")

;; Sets up exec-path-from-shell so that Emacs will use the correct
;; environment variables
(load "shell-integration.el")

;; These customizations make it easier for you to navigate files,
;; switch buffers, and choose options from the minibuffer.
(load "navigation.el")

;; These customizations change the way emacs looks and disable/enable
;; some user interface elements
(load "ui.el")

;; These customizations make editing a bit nicer.
(load "editing.el")

;; Hard-to-categorize customizations
(load "misc.el")

;; For editing lisps
(load "elisp-editing.el")

;; Langauage-specific
(load "setup-clojure.el")
(load "setup-js.el")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(coffee-tab-width 2))

;; CUA mode allows to use C-x, C-c, C-v, C-z... for copy, cut, paste, undo...
;; and also  
(cua-mode t)


;; key bindings
;; sa: http://www.emacswiki.org/emacs/EmacsForMacOS
(when (eq system-type 'darwin) ;; mac specific settings
  (setq mac-option-modifier 'meta)       ;; left option key is META
  (setq mac-right-option-modifier nil)   ;; right option key is for OS X (key combinations)
  (global-set-key [kp-delete] 'delete-char) ;; sets fn-delete to be right-delete
  )


;; list directories (ls) for mac
(if (eq system-type 'darwin)
    (setq insert-directory-program (executable-find "gls")))


;; Move deleted files to trash
(setq delete-by-moving-to-trash t)

  
;; Don't show ^M when file has mixed line endings
(defun remove-dos-eol ()
  "Do not show ^M in files containing mixed UNIX and DOS line endings."
  (interactive)
  (setq buffer-display-table (make-display-table))
  (aset buffer-display-table ?\^M []))

(add-hook 'text-mode-hook 'remove-dos-eol)  


;; Tab/Space Settings
(setq-default tab-width 2)
;; Permanently force Emacs to indent with spaces, never with TABs:
(setq-default indent-tabs-mode nil)

(setq cua-auto-tabify-rectangles nil) ;; Don't tabify after rectangle commands
(setq transient-mark-mode t) ;; turns on visual feedback on selections.
(setq cua-keep-region-after-copy t) ;; Standard Windows behaviour
(setq x-select-enable-clipboard t)
(if (>= emacs-major-version 24)
  (setq interprogram-paste-function 'x-selection-value)
  (setq interprogram-paste-function 'x-cut-buffer-or-selection-value) )   



;; Commands for uppercase/downcase
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)





;; Match parentheses.  Useful to be sure you've closed everything up.
(show-paren-mode t)


;; C++ mode adjustment
(add-hook 'c++-mode-hook
  '(lambda ()
     (c-set-style "stroustrup")
     (setq indent-tabs-mode nil)))




;; Set context menu of artist-mode (painting ASCII art) to right click instead of middle click
(eval-after-load "artist"
  '(define-key artist-mode-map [(down-mouse-3)] 'artist-mouse-choose-operation)
)

;; Transient selection
(transient-mark-mode 1)

;; delete selection
(delete-selection-mode)


;; Oberon mode
(add-to-list 'auto-mode-alist '("\\.Mod\\'" . oberon-mode))
(add-to-list 'auto-mode-alist '("\\.Mos\\'" . oberon-mode))
(autoload 'oberon-mode "oberon" nil t)
(add-hook 'oberon-mode-hook (lambda () (abbrev-mode t)))
