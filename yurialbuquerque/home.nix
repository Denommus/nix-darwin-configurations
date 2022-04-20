{ config, pkgs, lib, ... }:
let
  myAspell = pkgs.aspellWithDicts (d: [d.en d.pt_BR]);
  setUserVariables = pkgs.writeShellScript "set-user-variables" ''
  source /etc/bashrc
  for i in $(export); do
      var=$(echo $i|sed 's/=.*//')
      val=$(echo $i|sed -e 's/^[^=]*=//' -e 's/^"//' -e 's/"$//')
      [[ $val != "" ]] && {
         launchctl setenv $var $val
      }
  done
  '';
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

  home.activation = {
    emacsApp = lib.hm.dag.entryAfter ["writeBoundary"] ''
    rm -rf /Users/yurialbuquerque/Applications/Emacs.app
    cp -r ${config.programs.emacs.finalPackage}/Applications/Emacs.app /Users/yurialbuquerque/Applications/Emacs.app
    defaults write com.apple.dock ResetLaunchPad -bool true;killall Dock
    '';
  };

  launchd.agents."setuservariables.plist" = {
    enable = true;
    config = {
      Label = "setuservariables";
      Program = "${setUserVariables}";
      RunAtLoad = true;
      EnvironmentVariables = {
        HOME = "/Users/yurialbuquerque";
        USER = "yurialbuquerque";
      };
    };
  };
}
