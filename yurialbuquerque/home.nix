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
    myAspell
    rustup
    rust-analyzer
    gcc
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

  launchd.agents."setenv.PATH.plist" = {
    enable  = true;
    config = {
      Label = "setenv.PATH";
      ProgramArguments = [ "/bin/launchctl" "setenv" "PATH" "$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin" ];
      RunAtLoad = true;
      EnvironmentVariables = {
        "HOME" = "/Users/yurialbuquerque";
        "USER" = "yurialbuquerque";
      };
    };
  };
}
