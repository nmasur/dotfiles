;; -*- mode: emacs-lisp -*-
;; This file is loaded by Spacemacs at startup.
;; It must be stored in your home directory.

(defun dotspacemacs/layers ()
  "Configuration Layers declaration.
You should not put any user code in this function besides modifying the variable
values."
  (setq-default
   ;; Base distribution to use. This is a layer contained in the directory
   ;; `+distribution'. For now available distributions are `spacemacs-base'
   ;; or `spacemacs'. (default 'spacemacs)
   dotspacemacs-distribution 'spacemacs
   ;; Lazy installation of layers (i.e. layers are installed only when a file
   ;; with a supported type is opened). Possible values are `all', `unused'
   ;; and `nil'. `unused' will lazy install only unused layers (i.e. layers
   ;; not listed in variable `dotspacemacs-configuration-layers'), `all' will
   ;; lazy install any layer that support lazy installation even the layers
   ;; listed in `dotspacemacs-configuration-layers'. `nil' disable the lazy
   ;; installation feature and you have to explicitly list a layer in the
   ;; variable `dotspacemacs-configuration-layers' to install it.
   ;; (default 'unused)
   dotspacemacs-enable-lazy-installation 'unused
   ;; If non-nil then Spacemacs will ask for confirmation before installing
   ;; a layer lazily. (default t)
   dotspacemacs-ask-for-lazy-installation t
   ;; If non-nil layers with lazy install support are lazy installed.
   ;; List of additional paths where to look for configuration layers.
   ;; Paths must have a trailing slash (i.e. `~/.mycontribs/')
   dotspacemacs-configuration-layer-path '()
   ;; List of configuration layers to load.
   dotspacemacs-configuration-layers
   '(go
     ruby
     vimscript
     php
     sql
     sml
     javascript
     html
     csv
     (rust :variables
           rust-format-on-save t)
     (lsp :variables
          lsp-ui-doc-enable nil
          lsp-ui-sideline-code-actions-prefix " "
          lsp-ui-sideline-show-hover nil
          lsp-rust-server 'rust-analyzer
          lsp-rust-analyzer-server-display-inlay-hints t
          lsp-rust-analyzer-cargo-watch-enable t)
     python
     ;; javascript
     helm
     (auto-completion :variables
          auto-completion-return-key-behavior nil
          auto-completion-tab-key-behavior 'complete
          auto-completion-enable-sort-by-usage t
          auto-completion-private-snippets-directory nil)
     ;; better-defaults
     emacs-lisp
     git
     markdown
     org
     osx
     ranger
     dash
     yaml
     terraform
     docker
     nginx
     restclient
     games
     xkcd
     ;; (shell :variables
     ;;        shell-default-height 30
     ;;        shell-default-position 'bottom)
     ;; spell-checking
     ;; syntax-checking
     (syntax-checking :variables
          syntax-checking-enable-tooltips nil)
     ;; version-control
     )
   ;; List of additional packages that will be installed without being
   ;; wrapped in a layer. If you need some configuration for these
   ;; packages, then consider creating a layer. You can also put the
   ;; configuration in `dotspacemacs/user-config'.
   dotspacemacs-additional-packages '(dockerfile-mode)
   ;; A list of packages that cannot be updated.
   dotspacemacs-frozen-packages '()
   ;; A list of packages that will not be installed and loaded.
   dotspacemacs-excluded-packages '()
   ;; Defines the behaviour of Spacemacs when installing packages.
   ;; Possible values are `used-only', `used-but-keep-unused' and `all'.
   ;; `used-only' installs only explicitly used packages and uninstall any
   ;; unused packages as well as their unused dependencies.
   ;; `used-but-keep-unused' installs only the used packages but won't uninstall
   ;; them if they become unused. `all' installs *all* packages supported by
   ;; Spacemacs and never uninstall them. (default is `used-only')
   dotspacemacs-install-packages 'used-only))

(defun dotspacemacs/init ()
  "Initialization function.
This function is called at the very startup of Spacemacs initialization
before layers configuration.
You should not put any user code in there besides modifying the variable
values."
  ;; This setq-default sexp is an exhaustive list of all the supported
  ;; spacemacs settings.
  (setq-default
   ;; If non nil ELPA repositories are contacted via HTTPS whenever it's
   ;; possible. Set it to nil if you have no way to use HTTPS in your
   ;; environment, otherwise it is strongly recommended to let it set to t.
   ;; This variable has no effect if Emacs is launched with the parameter
   ;; `--insecure' which forces the value of this variable to nil.
   ;; (default t)
   dotspacemacs-elpa-https t
   ;; Maximum allowed time in seconds to contact an ELPA repository.
   dotspacemacs-elpa-timeout 5
   ;; If non nil then spacemacs will check for updates at startup
   ;; when the current branch is not `develop'. Note that checking for
   ;; new versions works via git commands, thus it calls GitHub services
   ;; whenever you start Emacs. (default nil)
   dotspacemacs-check-for-update nil
   ;; If non-nil, a form that evaluates to a package directory. For example, to
   ;; use different package directories for different Emacs versions, set this
   ;; to `emacs-version'.
   dotspacemacs-elpa-subdirectory nil
   ;; One of `vim', `emacs' or `hybrid'.
   ;; `hybrid' is like `vim' except that `insert state' is replaced by the
   ;; `hybrid state' with `emacs' key bindings. The value can also be a list
   ;; with `:variables' keyword (similar to layers). Check the editing styles
   ;; section of the documentation for details on available variables.
   ;; (default 'vim)
   dotspacemacs-editing-style 'vim
   ;; NO IDEA WHAT THIS IS
   dotspacemacs-mode-line-theme 'spacemacs
   ;; If non nil output loading progress in `*Messages*' buffer. (default nil)
   dotspacemacs-verbose-loading nil
   ;; Specify the startup banner. Default value is `official', it displays
   ;; the official spacemacs logo. An integer value is the index of text
   ;; banner, `random' chooses a random text banner in `core/banners'
   ;; directory. A string value must be a path to an image format supported
   ;; by your Emacs build.
   ;; If the value is nil then no banner is displayed. (default 'official)
   dotspacemacs-startup-banner 'official
   ;; List of items to show in startup buffer or an association list of
   ;; the form `(list-type . list-size)`. If nil then it is disabled.
   ;; Possible values for list-type are:
   ;; `recents' `bookmarks' `projects' `agenda' `todos'."
   ;; List sizes may be nil, in which case
   ;; `spacemacs-buffer-startup-lists-length' takes effect.
   dotspacemacs-startup-lists '((recents . 5)
                                (projects . 7))
   ;; True if the home buffer should respond to resize events.
   dotspacemacs-startup-buffer-responsive t
   ;; Default major mode of the scratch buffer (default `text-mode')
   dotspacemacs-scratch-mode 'text-mode
   ;; List of themes, the first of the list is loaded when spacemacs starts.
   ;; Press <SPC> T n to cycle to the next theme in the list (works great
   ;; with 2 themes variants, one dark and one light)
   dotspacemacs-themes '(spacemacs-dark
                         spacemacs-light)
   ;; If non nil the cursor color matches the state color in GUI Emacs.
   dotspacemacs-colorize-cursor-according-to-state t
   ;; Default font, or prioritized list of fonts. `powerline-scale' allows to
   ;; quickly tweak the mode-line size to make separators look not too crappy.
   dotspacemacs-default-font '("Fira Mono for Powerline"
                               :size 15
                               :weight normal
                               :width normal
                               :powerline-scale 1.1)
   ;; The leader key
   dotspacemacs-leader-key "SPC"
   ;; The key used for Emacs commands (M-x) (after pressing on the leader key).
   ;; (default "SPC")
   dotspacemacs-emacs-command-key "SPC"
   ;; The key used for Vim Ex commands (default ":")
   dotspacemacs-ex-command-key ":"
   ;; The leader key accessible in `emacs state' and `insert state'
   ;; (default "M-m")
   dotspacemacs-emacs-leader-key "M-m"
   ;; Major mode leader key is a shortcut key which is the equivalent of
   ;; pressing `<leader> m`. Set it to `nil` to disable it. (default ",")
   dotspacemacs-major-mode-leader-key ","
   ;; Major mode leader key accessible in `emacs state' and `insert state'.
   ;; (default "C-M-m")
   dotspacemacs-major-mode-emacs-leader-key "C-M-m"
   ;; These variables control whether separate commands are bound in the GUI to
   ;; the key pairs C-i, TAB and C-m, RET.
   ;; Setting it to a non-nil value, allows for separate commands under <C-i>
   ;; and TAB or <C-m> and RET.
   ;; In the terminal, these pairs are generally indistinguishable, so this only
   ;; works in the GUI. (default nil)
   dotspacemacs-distinguish-gui-tab nil
   ;; If non nil `Y' is remapped to `y$' in Evil states. (default nil)
   dotspacemacs-remap-Y-to-y$ nil
   ;; If non-nil, the shift mappings `<' and `>' retain visual state if used
   ;; there. (default t)
   dotspacemacs-retain-visual-state-on-shift t
   ;; If non-nil, J and K move lines up and down when in visual mode.
   ;; (default nil)
   dotspacemacs-visual-line-move-text nil
   ;; If non nil, inverse the meaning of `g' in `:substitute' Evil ex-command.
   ;; (default nil)
   dotspacemacs-ex-substitute-global nil
   ;; Name of the default layout (default "Default")
   dotspacemacs-default-layout-name "Default"
   ;; If non nil the default layout name is displayed in the mode-line.
   ;; (default nil)
   dotspacemacs-display-default-layout nil
   ;; If non nil then the last auto saved layouts are resume automatically upon
   ;; start. (default nil)
   dotspacemacs-auto-resume-layouts nil
   ;; Size (in MB) above which spacemacs will prompt to open the large file
   ;; literally to avoid performance issues. Opening a file literally means that
   ;; no major mode or minor modes are active. (default is 1)
   dotspacemacs-large-file-size 1
   ;; Location where to auto-save files. Possible values are `original' to
   ;; auto-save the file in-place, `cache' to auto-save the file to another
   ;; file stored in the cache directory and `nil' to disable auto-saving.
   ;; (default 'cache)
   dotspacemacs-auto-save-file-location 'cache
   ;; Maximum number of rollback slots to keep in the cache. (default 5)
   dotspacemacs-max-rollback-slots 5
   ;; If non nil, `helm' will try to minimize the space it uses. (default nil)
   dotspacemacs-helm-resize nil
   ;; if non nil, the helm header is hidden when there is only one source.
   ;; (default nil)
   dotspacemacs-helm-no-header nil
   ;; define the position to display `helm', options are `bottom', `top',
   ;; `left', or `right'. (default 'bottom)
   dotspacemacs-helm-position 'bottom
   ;; Controls fuzzy matching in helm. If set to `always', force fuzzy matching
   ;; in all non-asynchronous sources. If set to `source', preserve individual
   ;; source settings. Else, disable fuzzy matching in all sources.
   ;; (default 'always)
   dotspacemacs-helm-use-fuzzy 'always
   ;; If non nil the paste micro-state is enabled. When enabled pressing `p`
   ;; several times cycle between the kill ring content. (default nil)
   dotspacemacs-enable-paste-transient-state nil
   ;; Which-key delay in seconds. The which-key buffer is the popup listing
   ;; the commands bound to the current keystroke sequence. (default 0.4)
   dotspacemacs-which-key-delay 0.4
   ;; Which-key frame position. Possible values are `right', `bottom' and
   ;; `right-then-bottom'. right-then-bottom tries to display the frame to the
   ;; right; if there is insufficient space it displays it at the bottom.
   ;; (default 'bottom)
   dotspacemacs-which-key-position 'bottom
   ;; If non nil a progress bar is displayed when spacemacs is loading. This
   ;; may increase the boot time on some systems and emacs builds, set it to
   ;; nil to boost the loading time. (default t)
   dotspacemacs-loading-progress-bar t
   ;; If non nil the frame is fullscreen when Emacs starts up. (default nil)
   ;; (Emacs 24.4+ only)
   dotspacemacs-fullscreen-at-startup nil
   ;; If non nil `spacemacs/toggle-fullscreen' will not use native fullscreen.
   ;; Use to disable fullscreen animations in OSX. (default nil)
   dotspacemacs-fullscreen-use-non-native nil
   ;; If non nil the frame is maximized when Emacs starts up.
   ;; Takes effect only if `dotspacemacs-fullscreen-at-startup' is nil.
   ;; (default nil) (Emacs 24.4+ only)
   dotspacemacs-maximized-at-startup nil
   ;; A value from the range (0..100), in increasing opacity, which describes
   ;; the transparency level of a frame when it's active or selected.
   ;; Transparency can be toggled through `toggle-transparency'. (default 90)
   dotspacemacs-active-transparency 90
   ;; A value from the range (0..100), in increasing opacity, which describes
   ;; the transparency level of a frame when it's inactive or deselected.
   ;; Transparency can be toggled through `toggle-transparency'. (default 90)
   dotspacemacs-inactive-transparency 90
   ;; If non nil show the titles of transient states. (default t)
   dotspacemacs-show-transient-state-title t
   ;; If non nil show the color guide hint for transient state keys. (default t)
   dotspacemacs-show-transient-state-color-guide t
   ;; If non nil unicode symbols are displayed in the mode line. (default t)
   dotspacemacs-mode-line-unicode-symbols t
   ;; If non nil smooth scrolling (native-scrolling) is enabled. Smooth
   ;; scrolling overrides the default behavior of Emacs which recenters point
   ;; when it reaches the top or bottom of the screen. (default t)
   dotspacemacs-smooth-scrolling t
   ;; Control line numbers activation.
   ;; If set to `t' or `relative' line numbers are turned on in all `prog-mode' and
   ;; `text-mode' derivatives. If set to `relative', line numbers are relative.
   ;; This variable can also be set to a property list for finer control:
   ;; '(:relative nil
   ;;   :disabled-for-modes dired-mode
   ;;                       doc-view-mode
   ;;                       markdown-mode
   ;;                       org-mode
   ;;                       pdf-view-mode
   ;;                       text-mode
   ;;   :size-limit-kb 1000)
   ;; (default nil)
   dotspacemacs-line-numbers 'relative
   ;; Code folding method. Possible values are `evil' and `origami'.
   ;; (default 'evil)
   dotspacemacs-folding-method 'evil
   ;; If non-nil smartparens-strict-mode will be enabled in programming modes.
   ;; (default nil)
   dotspacemacs-smartparens-strict-mode nil
   ;; If non-nil pressing the closing parenthesis `)' key in insert mode passes
   ;; over any automatically added closing parenthesis, bracket, quote, etc…
   ;; This can be temporary disabled by pressing `C-q' before `)'. (default nil)
   dotspacemacs-smart-closing-parenthesis nil
   ;; Select a scope to highlight delimiters. Possible values are `any',
   ;; `current', `all' or `nil'. Default is `all' (highlight any scope and
   ;; emphasis the current one). (default 'all)
   dotspacemacs-highlight-delimiters 'all
   ;; If non nil, advise quit functions to keep server open when quitting.
   ;; (default nil)
   dotspacemacs-persistent-server nil
   ;; List of search tool executable names. Spacemacs uses the first installed
   ;; tool of the list. Supported tools are `ag', `pt', `ack' and `grep'.
   ;; (default '("ag" "pt" "ack" "grep"))
   dotspacemacs-search-tools '("ag" "pt" "ack" "grep")
   ;; The default package repository used if no explicit repository has been
   ;; specified with an installed package.
   ;; Not used for now. (default nil)
   dotspacemacs-default-package-repository nil
   ;; Delete whitespace while saving buffer. Possible values are `all'
   ;; to aggressively delete empty line and long sequences of whitespace,
   ;; `trailing' to delete only the whitespace at end of lines, `changed'to
   ;; delete only whitespace for changed lines or `nil' to disable cleanup.
   ;; (default nil)
   dotspacemacs-whitespace-cleanup nil
   ))

(defun dotspacemacs/user-init ()
  "Initialization function for user code.
It is called immediately after `dotspacemacs/init', before layer configuration
executes.
 This function is mostly useful for variables that need to be set
before packages are loaded. If you are unsure, you should try in setting them in
`dotspacemacs/user-config' first."
  )

(defun dotspacemacs/user-config ()
  "Configuration function for user code.
This function is called at the very end of Spacemacs initialization after
layers configuration.
This is the place where most of your configurations should be done. Unless it is
explicitly specified that a variable should be set before a package is loaded,
you should place your code here."

  ;; Sets Spacemacs macOS window view settings
  (add-to-list 'default-frame-alist
              '(ns-transparent-titlebar . t))

  (add-to-list 'default-frame-alist
              '(ns-appearance . dark)) ;; or light - depending on your theme

  ;; Sets window size and position
  (if (eq system-type 'darwin)
      ;; If Mac
      (setq initial-frame-alist '((top . 10) (left . 160) (width . 160) (height . 64)))
      ;; Else non-Mac
      (setq initial-frame-alist '((top . 20) (left . 30) (width . 130) (height . 57)))
  )

  ;; Org Mode -- count empty lines as blank separators
  (setq org-cycle-separator-lines -1)

  ;; Org Mode -- agenda files
  (setq org-agenda-files (list "~/Dropbox (Take-Two)/org/tasks"))

  ;; Org Mode -- capture file
  (setq org-default-notes-file "~/Dropbox (Take-Two)/org/tasks/capture.org")

  ;; Ranger Mode -- kill all the buffers on exit
  (setq ranger-cleanup-on-disable t)

  ;; Helm -- use ripgrep (rg) instead of silver searcher (ag)
  (setq helm-ag-base-command "rg --vimgrep --no-heading --smart-case")

  ;; Autocomplete -- help tooltips
  (setq auto-completion-enable-help-tooltip t)

  ;; Escape parenthesis
  (define-key evil-insert-state-map (kbd "M-l") 'sp-up-sexp)

  ;; Python Mode -- code folding
  (define-key evil-normal-state-map (kbd "z i") 'hs-hide-level)

  ;; Adds environment variables
  (setq exec-path-from-shell-arguments '("-l"))
  ;; (with-temp-buffer
  ;;   (insert-file-contents "/Users/noah.masur/Documents/GitHub/dotfiles/env.txt")
  ;;   (while (search-forward-regexp "\\(.*\\)\n?" nil t)
  ;;     (exec-path-from-shell-copy-env (match-string 1))
  ;;   ))
  ;; (defun source-file-and-get-envs (filename)
  ;;   (let* ((cmd (concat ". " filename "; env"))
  ;;          (env-str (shell-command-to-string cmd))
  ;;          (env-lines (split-string env-str "\n"))
  ;;          (envs (mapcar (lambda (s) (replace-regexp-in-string "=.*$" "" s)) env-lines)))
  ;;     (delete "" envs)))
  ;; (exec-path-from-shell-copy-envs (source-file-and-get-envs "/Users/noah.masur/.bash_profile"))

  ;; Starts emacsclient server to receive terminal commands

  ;; Add QR code
  (defun kisaragi/qr-encode (str &optional buf)
    "Encode STR as a QR code.

  Return a new buffer or BUF with the code in it."
    (interactive "MString to encode: ")
    (let ((buffer (get-buffer-create (or buf "*QR Code*")))
          (format (if (display-graphic-p) "PNG" "UTF8"))
          (inhibit-read-only t))
      (with-current-buffer buffer
        (delete-region (point-min) (point-max)))
      (make-process
      :name "qrencode" :buffer buffer
      :command `("qrencode" ,str "-t" ,format "-o" "-")
      :coding 'no-conversion
      ;; seems only the filter function is able to move point to top
      :filter (lambda (process string)
                (with-current-buffer (process-buffer process)
                  (insert string)
                  (goto-char (point-min))
                  (set-marker (process-mark process) (point))))
      :sentinel (lambda (process change)
                  (when (string= change "finished\n")
                    (with-current-buffer (process-buffer process)
                      (cond ((string= format "PNG")
                              (image-mode)
                              (image-transform-fit-to-height))
                            (t ;(string= format "UTF8")
                              (text-mode)
                              (decode-coding-region (point-min) (point-max) 'utf-8)))))))
      (when (called-interactively-p 'interactive)
        (display-buffer buffer))
      buffer))

  (org-reload)

  (server-start)
  )

;; Do not write anything past this comment. This is where Emacs will
;; auto-generate custom variable definitions.
(defun dotspacemacs/emacs-custom-settings ()
  "Emacs custom settings.
This is an auto-generated function, do not modify its content directly, use
Emacs customize menu instead.
This function is called at the very end of Spacemacs initialization."
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (godoctor go-tag go-rename go-impl go-guru go-gen-test go-fill-struct go-eldoc flycheck-golangci-lint counsel-gtags counsel swiper company-go go-mode seeing-is-believing rvm ruby-tools ruby-test-mode ruby-refactor ruby-hash-syntax rubocopfmt rubocop rspec-mode robe rbenv rake minitest helm-gtags ggtags enh-ruby-mode dap-mode bui ivy chruby bundler inf-ruby tern company-quickhelp yasnippet-snippets yapfify yaml-mode xkcd ws-butler writeroom-mode visual-fill-column winum web-mode web-beautify volatile-highlights vimrc-mode vi-tilde-fringe uuidgen typit mmt treemacs-projectile treemacs-persp treemacs-magit treemacs-icons-dired treemacs-evil toml-mode toc-org tagedit symon symbol-overlay sudoku string-inflection sql-indent spaceline-all-the-icons all-the-icons memoize spaceline powerline smeargle slim-mode scss-mode sass-mode reveal-in-osx-finder restclient-helm restart-emacs ranger rainbow-delimiters racer pytest pyenv-mode py-isort pug-mode prettier-js popwin pippel pipenv pyvenv pip-requirements phpunit phpcbf php-extras php-auto-yasnippets persp-mode password-generator paradox pacmacs overseer osx-trash osx-dictionary osx-clipboard orgit org-superstar org-projectile org-category-capture org-present org-pomodoro alert log4e gntp org-mime org-download org-cliplink org-brain open-junk-file ob-sml sml-mode ob-restclient ob-http nodejs-repl nginx-mode nameless move-text mmm-mode markdown-toc magit-svn magit-section magit-gitflow magit-popup macrostep lsp-ui lsp-treemacs treemacs pfuture lsp-python-ms lorem-ipsum livid-mode skewer-mode live-py-mode link-hint launchctl json-navigator hierarchy js2-refactor multiple-cursors js2-mode js-doc indent-guide importmagic epc ctable concurrent deferred impatient-mode simple-httpd hungry-delete htmlize hl-todo highlight-parentheses highlight-numbers parent-mode highlight-indentation helm-xref helm-themes helm-swoop helm-pydoc helm-purpose window-purpose imenu-list helm-projectile helm-org-rifle helm-org helm-mode-manager helm-make helm-lsp lsp-mode spinner ht dash-functional helm-ls-git helm-gitignore helm-git-grep helm-flx helm-descbinds helm-dash dash-docs helm-css-scss helm-company helm-c-yasnippet helm-ag haml-mode google-translate golden-ratio gnuplot gitignore-templates gitignore-mode gitconfig-mode gitattributes-mode git-timemachine git-messenger git-link gh-md geben fuzzy flycheck-rust flycheck-pos-tip pos-tip flycheck-package package-lint let-alist flycheck-elsa flycheck flx-ido flx fill-column-indicator fancy-battery eyebrowse expand-region evil-visualstar evil-visual-mark-mode evil-unimpaired evil-tutor evil-textobj-line evil-surround evil-org evil-numbers evil-nerd-commenter evil-matchit evil-magit magit git-commit with-editor evil-lisp-state evil-lion evil-indent-plus evil-iedit-state evil-goggles evil-exchange evil-escape evil-ediff evil-cleverparens smartparens evil-args evil-anzu anzu eval-sexp-fu emr iedit clang-format projectile paredit list-utils pkg-info epl emmet-mode elisp-slime-nav editorconfig dumb-jump drupal-mode dockerfile-mode docker transient tablist json-mode docker-tramp json-snatcher json-reformat devdocs dash-at-point dactyl-mode cython-mode csv-mode company-web web-completion-data company-terraform terraform-mode hcl-mode company-statistics company-restclient restclient know-your-http-well company-phpactor phpactor composer php-runtime request company-php ac-php-core xcscope php-mode company-anaconda company column-enforce-mode clean-aindent-mode centered-cursor-mode cargo markdown-mode rust-mode blacken auto-yasnippet yasnippet auto-highlight-symbol auto-compile packed anaconda-mode pythonic f dash s aggressive-indent ace-window ace-link ace-jump-helm-line helm avy helm-core ac-ispell auto-complete popup 2048-game which-key use-package pcre2el org-plus-contrib hydra lv hybrid-mode font-lock+ evil goto-chg undo-tree dotenv-mode diminish bind-map bind-key async))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
)
