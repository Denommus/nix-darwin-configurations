(defun nix-haskell-sandbox-setup ()
  (make-local-variable 'lsp-haskell-server-wrapper-function)
  (setq lsp-haskell-server-wrapper-function
        (lambda (argv)
          (apply #'nix-shell-command (nix-current-sandbox) argv)))
  (lsp))
(add-hook 'haskell-mode-hook #'subword-mode)
(add-hook 'haskell-mode-hook #'nix-haskell-sandbox-setup)
(add-hook 'haskell-literate-mode-hook #'nix-haskell-sandbox-setup)
