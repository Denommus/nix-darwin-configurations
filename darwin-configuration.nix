{ config, pkgs, lib, ... }:

let
  setAllVariables = pkgs.writeShellScript "set-all-variables" ''
  su yurialbuquerque -c "source /etc/bashrc"
  for i in $(export); do
      var=$(echo $i|sed 's/=.*//')
      val=$(echo $i|sed -e 's/^[^=]*=//' -e 's/^"//' -e 's/"$//')
      [[ $val != "" ]] && {
         launchctl setenv $var $val
      }
  done
  '';
in
{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs;
    [ vim
      gitFull
      gnupg
    ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  # services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina
  # programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
  services.nix-daemon.enable = true;
  services.activate-system.enable = true;
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
    experimental-features = nix-command flakes
    auto-optimise-store = true
    '';
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  nixpkgs.config.allowUnfree = true;

  homebrew = {
    enable = true;
    brews = [
      "docker-compose"
      "awscli"
    ];
    casks = [
      "element"
      "slack"
      "dropbox"
      "keepassxc"
      "docker"
      "spotify"
      "zoom"
      "discord"
      "firefox"
    ];
    taps = [
      "homebrew/cask"
    ];
    cleanup = "zap";
  };

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      anonymousPro
      ubuntu_font_family
      wqy_microhei
      wqy_zenhei
      ttf-tw-moe
    ];
  };

  users.users."yurialbuquerque" = {
    home = "/Users/yurialbuquerque";
    shell = "/bin/zsh";
  };

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  environment.launchAgents."setallenv.plist".text = ''
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
  <plist version="1.0">
  	<dict>
  		<key>Label</key>
  		<string>setallenv</string>
  		<key>Program</key>
  		<string>${setAllVariables}</string>
  		<key>RunAtLoad</key>
  		<true/>
  	</dict>
  </plist>
  '';
}
