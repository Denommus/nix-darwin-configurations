(defun haskell-wrapper (argv)
  (let ((result (apply #'nix-shell-command (nix-current-sandbox) argv)))
    (message "HASKELL LANGUAGE SERVER %S" result)
    result))
(setq lsp-haskell-server-wrapper-function #'haskell-wrapper)
(defun nix-haskell-sandbox-setup ()
  (make-local-variable 'flycheck-haskell-hlint-executable)
  (setq flycheck-haskell-hlint-executable (mapconcat #'identity (nix-shell-command (nix-current-sandbox) "hlint") " "))
  (make-local-variable 'flycheck-haskell-stack-ghc-executable)
  (setq flycheck-haskell-hlint-executable (mapconcat #'identity (nix-shell-command (nix-current-sandbox) "stack") " "))
  (lsp))
(add-hook 'haskell-mode-hook #'subword-mode)
(add-hook 'haskell-mode-hook #'nix-haskell-sandbox-setup)
(add-hook 'haskell-literate-mode-hook #'nix-haskell-sandbox-setup)