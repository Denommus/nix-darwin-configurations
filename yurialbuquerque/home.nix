{ config, pkgs, ... }:
let myAspell = pkgs.aspellWithDicts (d: [d.en d.pt_BR]);
in {
  programs.emacs.init = import emacs/emacs.nix { inherit pkgs; };
  programs.emacs.enable = true;
  services.emacs.client.enable = true;

  home.sessionVariablesExtra = ''
  export EDITOR=emacsclient
  '';
  home.packages = with pkgs; [
    rustup
    rust-analyzer
    gcc
    keepassxc
  ];
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    history.extended = true;
    oh-my-zsh = {
      enable = true;
      theme = "mortalscumbag";
      plugins = [
        "git"
      ];
    };
  };

  programs.git = {
    enable = true;
    ignores = [ "*~" ];
    lfs.enable = true;
    userEmail = "yuri.albuquerque@nextroll.com";
    userName = "Yuri Albuquerque";
    extraConfig = {
      pull.ff = "only";
      init.defaultBranch = "main";
    };
  };
}