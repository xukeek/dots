;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq user-full-name "xukeek"
      user-mail-address "okeoke1011@gmail.com"
      doom-scratch-intial-major-mode 'lisp-interaction-mode
      doom-font (font-spec :family "Iosevka" :size 15)
      doom-variable-pitch-font (font-spec :family "Libre Baskerville")
      doom-serif-font (font-spec :family "Libre Baskerville")
      doom-theme 'doom-one
      display-line-numbers-type nil
      system-time-locale "C"
      load-prefer-newer t

      company-idle-delay nil
      lsp-ui-sideline-enable nil
      lsp-enable-symbol-highlighting nil)

(setq org-directory "~/Dropbox/org/"
      org-ellipsis " ▼ "
      org-adapt-indentation nil
      org-habit-show-habits-only-for-today t)

(setq search-highlight t
      search-whitespace-regexp ".*?"
      isearch-lax-whitespace t
      isearch-regexp-lax-whitespace nil
      isearch-lazy-highlight t
      isearch-lazy-count t
      lazy-count-prefix-format " (%s/%s) "
      lazy-count-suffix-format nil
      isearch-yank-on-move 'shift
      isearch-allow-scroll 'unlimited)

(setq direnv-always-show-summary nil)

(remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-shortmenu)

(after! dired
  (setq dired-listing-switches "-aBhl  --group-directories-first"
        dired-dwim-target t
        dired-recursive-copies (quote always)
        dired-recursive-deletes (quote top)))

(use-package! dired-narrow
  :commands (dired-narrow-fuzzy)
  :init
  (map! :map dired-mode-map
        :desc "narrow" "/" #'dired-narrow-fuzzy))

(use-package! deadgrep
  :if (executable-find "rg")
  :init
  (map! "M-s" #'deadgrep))

(use-package! smerge-mode
  :bind (("C-c h s" . jethro/hydra-smerge/body))
  :init
  (defun jethro/enable-smerge-maybe ()
    "Auto-enable `smerge-mode' when merge conflict is detected."
    (save-excursion
      (goto-char (point-min))
      (when (re-search-forward "^<<<<<<< " nil :noerror)
        (smerge-mode 1))))
  (add-hook 'find-file-hook #'jethro/enable-smerge-maybe :append)
  :config
  (defhydra jethro/hydra-smerge (:color pink
                                        :hint nil
                                        :pre (smerge-mode 1)
                                        ;; Disable `smerge-mode' when quitting hydra if
                                        ;; no merge conflicts remain.
                                        :post (smerge-auto-leave))
    "
   ^Move^       ^Keep^               ^Diff^                 ^Other^
   ^^-----------^^-------------------^^---------------------^^-------
   _n_ext       _b_ase               _<_: upper/base        _C_ombine
   _p_rev       _u_pper           g   _=_: upper/lower       _r_esolve
   ^^           _l_ower              _>_: base/lower        _k_ill current
   ^^           _a_ll                _R_efine
   ^^           _RET_: current       _E_diff
   "
    ("n" smerge-next)
    ("p" smerge-prev)
    ("b" smerge-keep-base)
    ("u" smerge-keep-upper)
    ("l" smerge-keep-lower)
    ("a" smerge-keep-all)
    ("RET" smerge-keep-current)
    ("\C-m" smerge-keep-current)
    ("<" smerge-diff-base-upper)
    ("=" smerge-diff-upper-lower)
    (">" smerge-diff-base-lower)
    ("R" smerge-refine)
    ("E" smerge-ediff)
    ("C" smerge-combine-with-next)
    ("r" smerge-resolve)
    ("k" smerge-kill-current)
    ("q" nil "cancel" :color blue)))

(use-package! magit
  :init
  (map! "s-g" #'magit-status
        "C-c g" #'magit-status
        "s-G" #'magit-blame-addition
        "C-c G" #'magit-blame-addition)
  :config
  (transient-append-suffix 'magit-log "a"
    '("w" "Wip" magit-wip-log-current))
  (magit-define-popup-switch 'magit-log-popup
                             ?m "Omit merge commits" "--no-merges")
  (transient-append-suffix 'magit-log "-A"
    '("-m" "Omit merge commits" "--no-merges")))

(use-package! git-link
  :commands
  (git-link git-link-commit git-link-homepage)
  :custom
  (git-link-use-commit t))

(use-package! easy-kill
  :bind*
  (([remap kill-ring-save] . easy-kill)))

(use-package! smartparens
  :init
  (map! :map smartparens-mode-map
        "C-M-f" #'sp-forward-sexp
        "C-M-b" #'sp-backward-sexp
        "C-M-u" #'sp-backward-up-sexp
        "C-M-d" #'sp-down-sexp
        "C-M-p" #'sp-backward-down-sexp
        "C-M-n" #'sp-up-sexp
        "C-M-s" #'sp-splice-sexp
        "C-)" #'sp-forward-slurp-sexp
        "C-}" #'sp-forward-barf-sexp
        "C-(" #'sp-backward-slurp-sexp
        "C-M-)" #'sp-backward-slurp-sexp
        "C-M-)" #'sp-backward-barf-sexp))

(after! org
  (require 'org-habit)

  (with-eval-after-load 'flycheck
    (flycheck-add-mode 'proselint 'org-mode))

  (map! :leader
        :prefix "n"
        "c" #'org-capture)
  (map! :map org-mode-map
        "M-n" #'outline-next-visible-heading
        "M-p" #'outline-previous-visible-heading)
  (setq org-src-window-setup 'current-window
        org-return-follows-link t
        org-babel-load-languages '((emacs-lisp . t)
                                   (python . t)
                                   (dot . t)
                                   (R . t))
        org-confirm-babel-evaluate nil
        org-use-speed-commands t
        org-catch-invisible-edits 'show
        org-preview-latex-image-directory "/tmp/ltximg/"
        org-structure-template-alist '(("a" . "export ascii")
                                       ("c" . "center")
                                       ("C" . "comment")
                                       ("e" . "example")
                                       ("E" . "export")
                                       ("h" . "export html")
                                       ("l" . "export latex")
                                       ("q" . "quote")
                                       ("s" . "src")
                                       ("v" . "verse")
                                       ("el" . "src emacs-lisp")
                                       ("d" . "definition")
                                       ("t" . "theorem")))

  (defun jethro/org-archive-done-tasks ()
    "Archive all done tasks."
    (interactive)
    (org-map-entries 'org-archive-subtree "/DONE" 'file))
  (require 'find-lisp)
  (setq jethro/org-agenda-directory (file-truename "~/Dropbox/org/gtd/"))
  (setq org-agenda-files
        (find-lisp-find-files jethro/org-agenda-directory "\.org$")))

(defun jethro/find-or-create-olp (path &optional this-buffer)
  "Return a marker pointing to the entry at outline path OLP.
If anything goes wrong, throw an error, and if you need to do
something based on this error, you can catch it with
`condition-case'.

If THIS-BUFFER is set, the outline path does not contain a file,
only headings."
  (let* ((file (pop path))
         (level 1)
         (lmin 1)
         (lmax 1)
         (start (point-min))
         (end (point-max))
         found flevel)
    (unless (derived-mode-p 'org-mode)
      (error "Buffer %s needs to be in Org mode" buffer))
    (org-with-wide-buffer
     (goto-char start)
     (dolist (heading path)
       (let ((re (format org-complex-heading-regexp-format
                         (regexp-quote heading)))
             (cnt 0))
         (while (re-search-forward re end t)
           (setq level (- (match-end 1) (match-beginning 1)))
           (when (and (>= level lmin) (<= level lmax))
             (setq found (match-beginning 0) flevel level cnt (1+ cnt))))
         (when (> cnt 1)
           (error "Heading not unique on level %d: %s" lmax heading))
         (when (= cnt 0)
           ;; Create heading if it doesn't exist
           (goto-char end)
           (unless (bolp) (newline))
           (org-insert-heading nil nil t)
           (unless (= lmax 1) (org-do-demote))
           (insert heading)
           (setq end (point))
           (goto-char start)
           (while (re-search-forward re end t)
             (setq level (- (match-end 1) (match-beginning 1)))
             (when (and (>= level lmin) (<= level lmax))
               (setq found (match-beginning 0) flevel level cnt (1+ cnt))))))
       (goto-char found)
       (setq lmin (1+ flevel) lmax (+ lmin (if org-odd-levels-only 1 0)))
       (setq start found
             end (save-excursion (org-end-of-subtree t t))))
     (point-marker))))

(defun jethro/olp-current-buffer (&rest outline-path)
  "Find the OUTLINE-PATH of the current buffer."
  (let ((m (jethro/find-or-create-olp (cons (buffer-file-name) outline-path))))
    (set-buffer (marker-buffer m))
    (org-capture-put-target-region-and-position)
    (widen)
    (goto-char m)
    (set-marker m nil)))

(setq org-capture-templates
        `(("i" "Inbox" entry (file "~/Dropbox/org/gtd/inbox.org")
           ,(concat "* TODO %?\n"
                    "/Entered on/ %u"))
          ("e" "Inbox [mail]" entry (file "~/Dropbox/org/gtd/inbox.org")
           ,(concat "* TODO Process: \"%a\" %?\n"
                    "/Entered on/ %u"))
          ("c" "org-protocol-capture" entry (file "~/Dropbox/org/gtd/inbox.org")
           "* TODO [[%:link][%:description]]\n\n %i"
           :immediate-finish t)
          ("m" "Metacognition")
          ("mq" "Questions" entry (function ,(lambda ()
                                               (jethro/olp-current-buffer "Metacog" "Questions")))
           ,(concat "* TODO Q: %?\n"
                    "/Entered on/ %u"))
          ("mn" "Notes" entry (function ,(lambda ()
                                           (jethro/olp-current-buffer "Metacog" "Notes")))
           "* %?\n")))

(setq org-todo-keywords
      '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)")
        (sequence "WAITING(w@/!)" "HOLD(h@/!)" "|" "CANCELLED(c@/!)")))

(setq org-log-done 'time
      org-log-into-drawer t
      org-log-state-notes-insert-after-drawers nil)

(setq org-tag-alist '(("@errand" . ?e)
                      ("@office" . ?o)
                      ("@home" . ?h)
                      (:newline)
                      ("CANCELLED" . ?c)))

(setq org-fast-tag-selection-single-key nil)
(setq org-refile-use-outline-path 'file
      org-outline-path-complete-in-steps nil)
(setq org-refile-allow-creating-parent-nodes 'confirm
      org-refile-targets '((org-agenda-files . (:level . 1))))

(defvar jethro/org-agenda-bulk-process-key ?f
  "Default key for bulk processing inbox items.")

(defun jethro/org-process-inbox ()
  "Called in org-agenda-mode, processes all inbox items."
  (interactive)
  (org-agenda-bulk-mark-regexp "inbox:")
  (jethro/bulk-process-entries))

(defvar jethro/org-current-effort "1:00"
  "Current effort for agenda items.")

(defun jethro/my-org-agenda-set-effort (effort)
  "Set the effort property for the current headline."
  (interactive
   (list (read-string (format "Effort [%s]: " jethro/org-current-effort) nil nil jethro/org-current-effort)))
  (setq jethro/org-current-effort effort)
  (org-agenda-check-no-diary)
  (let* ((hdmarker (or (org-get-at-bol 'org-hd-marker)
                       (org-agenda-error)))
         (buffer (marker-buffer hdmarker))
         (pos (marker-position hdmarker))
         (inhibit-read-only t)
         newhead)
    (org-with-remote-undo buffer
      (with-current-buffer buffer
        (widen)
        (goto-char pos)
        (org-show-context 'agenda)
        (funcall-interactively 'org-set-effort nil jethro/org-current-effort)
        (end-of-line 1)
        (setq newhead (org-get-heading)))
      (org-agenda-change-all-lines newhead hdmarker))))

(defun jethro/org-agenda-process-inbox-item ()
  "Process a single item in the org-agenda."
  (org-with-wide-buffer
   (org-agenda-set-tags)
   (org-agenda-priority)
   (call-interactively 'jethro/my-org-agenda-set-effort)
   (org-agenda-refile nil nil t)))

(defun jethro/bulk-process-entries ()
  (if (not (null org-agenda-bulk-marked-entries))
      (let ((entries (reverse org-agenda-bulk-marked-entries))
            (processed 0)
            (skipped 0))
        (dolist (e entries)
          (let ((pos (text-property-any (point-min) (point-max) 'org-hd-marker e)))
            (if (not pos)
                (progn (message "Skipping removed entry at %s" e)
                       (cl-incf skipped))
              (goto-char pos)
              (let (org-loop-over-headlines-in-active-region) (funcall 'jethro/org-agenda-process-inbox-item))
              ;; `post-command-hook' is not run yet.  We make sure any
              ;; pending log note is processed.
              (when (or (memq 'org-add-log-note (default-value 'post-command-hook))
                        (memq 'org-add-log-note post-command-hook))
                (org-add-log-note))
              (cl-incf processed))))
        (org-agenda-redo)
        (unless org-agenda-persistent-marks (org-agenda-bulk-unmark-all))
        (message "Acted on %d entries%s%s"
                 processed
                 (if (= skipped 0)
                     ""
                   (format ", skipped %d (disappeared before their turn)"
                           skipped))
                 (if (not org-agenda-persistent-marks) "" " (kept marked)")))))

(defun jethro/org-inbox-capture ()
  (interactive)
  "Capture a task in agenda mode."
  (org-capture nil "i"))

(setq org-agenda-bulk-custom-functions `((,jethro/org-agenda-bulk-process-key jethro/org-agenda-process-inbox-item)))

(map! :map org-agenda-mode-map
      "i" #'org-agenda-clock-in
      "r" #'jethro/org-process-inbox
      "R" #'org-agenda-refile
      "c" #'jethro/org-inbox-capture)

(defun jethro/set-todo-state-next ()
  "Visit each parent task and change NEXT states to TODO"
  (org-todo "NEXT"))

(add-hook 'org-clock-in-hook 'jethro/set-todo-state-next 'append)

(use-package! org-clock-convenience
  :bind (:map org-agenda-mode-map
              ("<S-up>" . org-clock-convenience-timestamp-up)
              ("<S-down>" . org-clock-convenience-timestamp-down)
              ("o" . org-clock-convenience-fill-gap)
              ("e" . org-clock-convenience-fill-gap-both)))

(use-package! org-agenda
  :init
  (map! "<f1>" #'jethro/switch-to-agenda)
  (setq org-agenda-block-separator nil
        org-agenda-start-with-log-mode t)
  (defun jethro/switch-to-agenda ()
    (interactive)
    (org-agenda nil " "))
  :config
  (defun jethro/is-project-p ()
  "Any task with a todo keyword subtask"
  (save-restriction
    (widen)
    (let ((has-subtask)
          (subtree-end (save-excursion (org-end-of-subtree t)))
          (is-a-task (member (nth 2 (org-heading-components)) org-todo-keywords-1)))
      (save-excursion
        (forward-line 1)
        (while (and (not has-subtask)
                    (< (point) subtree-end)
                    (re-search-forward "^\*+ " subtree-end t))
          (when (member (org-get-todo-state) org-todo-keywords-1)
            (setq has-subtask t))))
      (and is-a-task has-subtask))))

  (defun jethro/skip-projects ()
  "Skip trees that are projects"
  (save-restriction
    (widen)
    (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
      (cond
       ((org-is-habit-p)
        next-headline)
       ((jethro/is-project-p)
        next-headline)
       (t
        nil)))))

  (setq org-columns-default-format "%40ITEM(Task) %Effort(EE){:} %CLOCKSUM(Time Spent) %SCHEDULED(Scheduled) %DEADLINE(Deadline)")
  (setq org-agenda-custom-commands `((" " "Agenda"
                                      ((agenda ""
                                               ((org-agenda-span 'week)
                                                (org-deadline-warning-days 365)))
                                       (todo "TODO"
                                             ((org-agenda-overriding-header "Inbox")
                                              (org-agenda-files '(,(expand-file-name "inbox.org" jethro/org-agenda-directory)))))
                                       (todo "TODO"
                                             ((org-agenda-overriding-header "Emails")
                                              (org-agenda-files '(,(expand-file-name "emails.org" jethro/org-agenda-directory)))))
                                       (todo "NEXT"
                                             ((org-agenda-overriding-header "In Progress")
                                              (org-agenda-files '(,(expand-file-name "projects.org" jethro/org-agenda-directory)))))
                                       (todo "TODO"
                                             ((org-agenda-overriding-header "Active Projects")
                                              (org-agenda-skip-function #'jethro/skip-projects)
                                              (org-agenda-files '(,(expand-file-name "projects.org" jethro/org-agenda-directory)))))
                                       (todo "TODO"
                                             ((org-agenda-overriding-header "One-off Tasks")
                                              (org-agenda-files '(,(expand-file-name "next.org" jethro/org-agenda-directory)))
                                              (org-agenda-skip-function '(org-agenda-skip-entry-if 'deadline 'scheduled)))))))))

(use-package! org-roam
  :commands (org-roam-insert org-roam-find-file org-roam-switch-to-buffer org-roam)
  :hook
  (after-init . org-roam-mode)
  :init
  (map! :leader
        :prefix "n"
        :desc "org-roam" "l" #'org-roam
        :desc "org-roam-insert" "i" #'org-roam-insert
        :desc "org-roam-switch-to-buffer" "b" #'org-roam-switch-to-buffer
        :desc "org-roam-find-file" "f" #'org-roam-find-file
        :desc "org-roam-show-graph" "g" #'org-roam-show-graph
        :desc "org-roam-insert" "i" #'org-roam-insert
        :desc "org-roam-capture" "c" #'org-roam-capture
        :desc "org-roam-dailies-capture-today" "j" #'org-roam-dailies-capture-today)
  (setq org-roam-directory (file-truename "~/Dropbox/org/braindump/org/")
        org-roam-db-gc-threshold most-positive-fixnum
        org-roam-graph-exclude-matcher "private"
        org-roam-tag-sources '(prop last-directory)
        org-id-link-to-org-use-id t)
  :config
  (setq org-roam-capture-templates
        '(("d" "default" plain (function org-roam--capture-get-point)
           "%?"
           :file-name "${slug}"
           :head "#+title: ${title}\n"
           :immediate-finish t
           :unnarrowed t)
          ("p" "private" plain (function org-roam-capture--get-point)
           "%?"
           :file-name "private/${slug}"
           :head "#+title: ${title}\n"
           :immediate-finish t
           :unnarrowed t)))
  (setq org-roam-capture-ref-templates
        '(("r" "ref" plain (function org-roam-capture--get-point)
           "%?"
           :file-name "${slug}"
           :head "#+roam_key: ${ref}
#+roam_tags: website
#+title: ${title}

- source :: ${ref}"
           :unnarrowed t)))
  (setq org-roam-dailies-directory "daily/")
  (setq org-roam-dailies-capture-templates
      '(("d" "default" entry
         #'org-roam-capture--get-point
         "* %?"
         :file-name "daily/%<%Y-%m-%d>"
         :head "#+title: %<%Y-%m-%d>\n\n")))
  (set-company-backend! 'org-mode '(company-capf)))

(after! org-ref
  (setq org-ref-default-bibliography `,(list (concat org-directory "braindump/org/biblio.bib"))))

(use-package! org-roam-protocol
  :after org-protocol)

(after! company
  (map! "M-/" #'company-complete))

(use-package! company-posframe
  :hook (company-mode . company-posframe-mode))

(after! (org-roam)
  (winner-mode +1)
  (map! :map winner-mode-map
        "<M-right>" #'winner-redo
        "<M-left>" #'winner-undo))

(use-package! ox-hugo
  :after org)

(use-package! org-download
  :commands
  org-download-dnd
  org-download-yank
  org-download-screenshot
  org-download-dnd-base64
  :init
  (map! :map org-mode-map
        "s-Y" #'org-download-screenshot
        "s-y" #'org-download-yank)
  (pushnew! dnd-protocol-alist
            '("^\\(?:https?\\|ftp\\|file\\|nfs\\):" . +org-dragndrop-download-dnd-fn)
            '("^data:" . org-download-dnd-base64))
  (advice-add #'org-download-enable :override #'ignore)
  :config
  (defun +org/org-download-method (link)
    (let* ((filename
            (file-name-nondirectory
             (car (url-path-and-query
                   (url-generic-parse-url link)))))
           ;; Create folder name with current buffer name, and place in root dir
           (dirname (concat "./images/"
                            (replace-regexp-in-string " " "_"
                                                      (downcase (file-name-base buffer-file-name)))))
           (filename-with-timestamp (format "%s%s.%s"
                                            (file-name-sans-extension filename)
                                            (format-time-string org-download-timestamp)
                                            (file-name-extension filename))))
      (make-directory dirname t)
      (expand-file-name filename-with-timestamp dirname)))
  :config
  (setq org-download-screenshot-method
        (cond (IS-MAC "screencapture -i %s")
              (IS-LINUX
               (cond ((executable-find "maim")  "maim -u -s %s")
                     ((executable-find "scrot") "scrot -s %s")))))
  (setq org-download-method '+org/org-download-method))

(use-package! citeproc-org
  :after org
  :config
  (citeproc-org-setup))

(use-package! mathpix.el
  :commands (mathpix-screenshot)
  :init
  (map! "C-x m" #'mathpix-screenshot)
  :config
  (setq mathpix-screenshot-method "flameshot gui -p %s"
        mathpix-app-id (with-temp-buffer (insert-file-contents "./secrets/mathpix-app-id") (buffer-string))
        mathpix-app-key (with-temp-buffer (insert-file-contents "./secrets/mathpix-app-key") (buffer-string))))

(use-package! anki-editor
  :commands (anki-editor-mode))

(use-package! gif-screencast
  :bind
  ("<f12>" . gif-screencast-start-or-stop))

(defun insert-date ()
  "Insert a timestamp according to locale's date and time format."
  (interactive)
  (insert (format-time-string "%c" (current-time))))

(use-package! outshine
  :commands (outshine-mode))

(after! ivy
  (map! :map ivy-minibuffer-map
        "S-SPC" nil)
  (add-to-list 'ivy-re-builders-alist '(counsel-projectile-find-file . ivy--regex-plus)))

(after! mixed-pitch
  (dolist (f (-filter (lambda (sym)
                        (s-prefix? "company-" (symbol-name sym)))
                      (face-list)))
    (pushnew! mixed-pitch-fixed-pitch-faces f)))

(use-package! org-roam-bibtex
  :after (org-roam)
  :hook (org-roam-mode . org-roam-bibtex-mode)
  :config
  (setq org-roam-bibtex-preformat-keywords
   '("=key=" "title" "url" "file" "author-or-editor" "keywords"))
  (setq orb-templates
        `(("r" "ref" plain (function org-roam-capture--get-point)
           ""
           :file-name "lit/${slug}"
           :head ,(concat
                   "#+setupfile: ./hugo_setup.org\n"
                   "#+title: ${=key=}: ${title}\n"
                   "#+roam_key: ${ref}\n\n"
                   "* ${title}\n"
                   "  :PROPERTIES:\n"
                   "  :Custom_ID: ${=key=}\n"
                   "  :URL: ${url}\n"
                   "  :AUTHOR: ${author-or-editor}\n"
                   "  :NOTER_DOCUMENT: %(orb-process-file-field \"${=key=}\")\n"
                   "  :NOTER_PAGE: \n"
                   "  :END:\n")
           :unnarrowed t))))

(use-package! bibtex-completion
  :config
  (setq bibtex-completion-notes-path "~/Dropbox/org/braindump/org/"
        bibtex-completion-bibliography "~/Dropbox/org/braindump/org/biblio.bib"
        bibtex-completion-pdf-field "file"
        bibtex-completion-notes-template-multiple-files
         (concat
          "#+title: ${title}\n"
          "#+roam_key: cite:${=key=}\n"
          "* TODO Notes\n"
          ":PROPERTIES:\n"
          ":Custom_ID: ${=key=}\n"
          ":NOTER_DOCUMENT: %(orb-process-file-field \"${=key=}\")\n"
          ":AUTHOR: ${author-abbrev}\n"
          ":JOURNAL: ${journaltitle}\n"
          ":DATE: ${date}\n"
          ":YEAR: ${year}\n"
          ":DOI: ${doi}\n"
          ":URL: ${url}\n"
          ":END:\n\n"
          )))

(use-package! nov
  :hook (nov-mode . variable-pitch-mode)
  :mode ("\\.\\(epub\\|mobi\\)\\'" . nov-mode))

(after! org-noter
  org-noter-doc-split-fraction '(0.57 0.43))

(use-package! yaml-mode
  :mode ("\\.yml\\'" . yaml-mode))

(use-package! org-roam-server)

(use-package! emmet-mode
  :hook
  ((sgml-mode . emmet-mode)
   (css-mode . emmet-mode)))


(defun jethro/open-with (arg)
  "Open visited file in default external program.
When in dired mode, open file under the cursor.
With a prefix ARG always prompt for command to use."
  (interactive "P")
  (let* ((current-file-name
          (if (eq major-mode 'dired-mode)
              (dired-get-file-for-visit)
            buffer-file-name))
         (open (pcase system-type
                 (`darwin "open")
                 ((or `gnu `gnu/linux `gnu/kfreebsd) "xdg-open")))
         (program (if (or arg (not open))
                      (read-shell-command "Open current file with: ")
                    open)))
    (call-process program nil 0 nil current-file-name)))

(map! "C-c o o" 'jethro/open-with)

(use-package! org-gcal
  :commands (org-gcal-sync)
  :config
  (setq org-gcal-client-id (password-store-get "gmail/org-gcal-client")
        org-gcal-client-secret (password-store-get "gmail/org-gcal-secret")
        org-gcal-file-alist `(("dckbhpq9bq13m03llerl09slgo@group.calendar.google.com" . ,(concat jethro/org-agenda-directory "calendars/lab.org"))
                              ("jethrokuan95@gmail.com" . ,(concat jethro/org-agenda-directory "calendars/personal.org")))))

(use-package prog-mode
  :config
  (add-hook 'prog-mode-hook 'outline-minor-mode)
  (add-hook 'prog-mode-hook 'hs-minor-mode))

(defun jethro/ledger-cleanup-csv ()
  (save-excursion
    (goto-char (point-min))
    (while (search-forward "\n" nil t)
      (beginning-of-line)
      (delete-horizontal-space)
      (end-of-line)
      (delete-horizontal-space)
      (when (string-equal (buffer-substring-no-properties (line-beginning-position) (line-end-position))
                          "")
        (delete-char -1)))))

(defun jethro/ledger-import-sc (file)
  (interactive "f")
  (let* ((cleaned-content (with-temp-buffer
                            (insert-file-contents file)
                            (jethro/ledger-cleanup-csv)
                            (buffer-string)))
         (lines (split-string cleaned-content "\n"))
         (account (completing-read "account: " (ledger-accounts-list-in-buffer))))
    (save-match-data
      (dolist (line lines)
        (let* ((items (split-string line ","))
               (date-maybe (car items)))
          (when (string-match "\\([0-9][0-9]\\)/\\([0-9][0-9]\\)/\\([0-9][0-9][0-9][0-9]\\)" date-maybe)
            (pcase-let ((`(_ ,info ,foreign ,sgd) items))
              (let ((date (format "%s/%s/%s" ;YYYY/MM/DD
                                  (match-string 3 date-maybe)
                                  (match-string 2 date-maybe)
                                  (match-string 1 date-maybe))))
                (when (string-match "SGD \\(.*\\) \\(DR\\|CR\\)" sgd)
                  (let ((cr-p (string-equal (match-string 2 sgd) "CR"))
                        (value (match-string 1 sgd)))
                    (insert date
                            " * " info "\n"
                            "    " account
                            "   " (if cr-p "-" "") "S$" value "\n"
                            "    " (completing-read info (ledger-accounts-list-in-buffer))
                            "\n\n\n")))))))))))

(after! org-latex
  (setq org-latex-pdf-process (list "latexmk -f -xelatex %f")))

(map!
 [backtab] #'+fold/toggle
 [C-tab] #'+fold/open-all
 [C-iso-lefttab] #'+fold/close-all)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(fci-rule-color "#544863")
 '(git-link-use-commit t t)
 '(jdee-db-active-breakpoint-face-colors (cons "#222228" "#40B4C4"))
 '(jdee-db-requested-breakpoint-face-colors (cons "#222228" "#74DFC4"))
 '(jdee-db-spec-breakpoint-face-colors (cons "#222228" "#4E415C"))
 '(objed-cursor-color "#964C7B")
 '(pdf-view-midnight-colors (cons "#FFFFFF" "#27212E"))
 '(rustic-ansi-faces
   ["#27212E" "#964C7B" "#74DFC4" "#FFE261" "#40B4C4" "#EB64B9" "#B4DCE7" "#FFFFFF"])
 '(safe-local-variable-values
   '((eval require 'org-roam-dev)
     (eval jethro/conditional-hugo-enable)
     (org-src-preserve-indentation)
     (eval require 'ol-info))))
