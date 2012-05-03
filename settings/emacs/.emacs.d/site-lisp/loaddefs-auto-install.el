;;; loaddefs-auto-install.el --- automatically extracted autoloads
;;
;;; Code:


;;;### (autoloads (auto-install-send-bug-report auto-install-buffer-save
;;;;;;  auto-install-buffer-diff auto-install-batch-edit auto-install-batch
;;;;;;  auto-install-compatibility-setup auto-install-buffer-quit
;;;;;;  auto-install-mode auto-install-dired-mark-files auto-install-update-emacswiki-package-name
;;;;;;  auto-install-from-dired auto-install-from-directory auto-install-from-library
;;;;;;  auto-install-from-gist auto-install-from-emacswiki auto-install-from-url
;;;;;;  auto-install-from-buffer) "auto-install" "auto-install.el"
;;;;;;  (20386 9325))
;;; Generated autoloads from auto-install.el

(autoload 'auto-install-from-buffer "auto-install" "\
Install the elisp file in the current buffer.

\(fn)" t nil)

(autoload 'auto-install-from-url "auto-install" "\
Install an elisp file from a given url.

\(fn &optional URL)" t nil)

(autoload 'auto-install-from-emacswiki "auto-install" "\
Install an elisp file from EmacsWiki.org.

\(fn &optional FILE)" t nil)

(autoload 'auto-install-from-gist "auto-install" "\
Install an elisp file from gist.github.com.

Optional argument GISTID-OR-URL is gist ID or URL for download
elisp file from gist.github.com.

\(fn &optional GISTID-OR-URL)" t nil)

(autoload 'auto-install-from-library "auto-install" "\
Update an elisp LIBRARY.
Default this function will found 'download url' from `auto-install-filter-url',
if not found, try to download from EmacsWiki.

\(fn &optional LIBRARY)" t nil)

(autoload 'auto-install-from-directory "auto-install" "\
Update elisp files under DIRECTORY from EmacsWiki.
You can use this command to update elisp file under DIRECTORY.

\(fn DIRECTORY)" t nil)

(autoload 'auto-install-from-dired "auto-install" "\
Update dired marked elisp files from EmacsWiki.org.
You can use this to download marked files in Dired asynchronously.

\(fn)" t nil)

(autoload 'auto-install-update-emacswiki-package-name "auto-install" "\
Update the list of elisp package names from `EmacsWiki'.
By default, this function will update package name forcibly.
If UNFORCED is non-nil, just update package name when `auto-install-package-name-list' is nil.

\(fn &optional UNFORCED)" t nil)

(autoload 'auto-install-dired-mark-files "auto-install" "\
Mark dired files that contain at `EmacsWiki.org'.

\(fn)" t nil)

(autoload 'auto-install-mode "auto-install" "\
Major mode for auto-installing elisp code.

\(fn)" t nil)

(autoload 'auto-install-buffer-quit "auto-install" "\
Quit from `auto-install' temporary buffer.

\(fn)" t nil)

(autoload 'auto-install-compatibility-setup "auto-install" "\
Install Compatibility commands for install-elisp.el users.

\(fn)" t nil)

(autoload 'auto-install-batch "auto-install" "\
Batch install many files (libraries and non-elisp files) in some extension.
EXTENSION-NAME is extension name for batch install.

Note that non-elisp can be installed only via `auto-install-batch'

\(fn &optional EXTENSION-NAME)" t nil)

(autoload 'auto-install-batch-edit "auto-install" "\
Edit auto-install-batch-list.el

\(fn)" t nil)

(autoload 'auto-install-buffer-diff "auto-install" "\
View different between old version.
This command just run when have exist old version.

\(fn)" t nil)

(autoload 'auto-install-buffer-save "auto-install" "\
Save downloaded content to file FILENAME.

\(fn &optional FILENAME)" t nil)

(autoload 'auto-install-send-bug-report "auto-install" "\


\(fn)" t nil)

;;;***

(provide 'loaddefs-auto-install)
;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; loaddefs-auto-install.el ends here
