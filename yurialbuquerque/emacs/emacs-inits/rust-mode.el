(defun nix-rust-sandbox-setup ()
  (make-local-variable 'lsp-rust-rls-server-command)
  (setq lsp-rust-rls-server-command (nix-shell-command (nix-current-sandbox) "rls"))
  (make-local-variable 'lsp-rust-analyzer-server-command)
  (setq lsp-rust-analyzer-server-command (nix-shell-command (nix-current-sandbox) "rust-analyzer"))
  (lsp))

(add-hook 'rust-mode-hook #'nix-rust-sandbox-setup)
