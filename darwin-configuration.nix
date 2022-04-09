{ config, pkgs, lib, ... }:

let
  envVarPlist = lib.mapAttrs' (name: value: lib.nameValuePair ("setenv.${name}.plist") ({
    text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
      <key>Label</key>
      <string>setenv.${name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>/usr/bin/sudo</string>
        <string>/bin/launchctl</string>
        <string>setenv</string>
        <string>${name}</string>
        <string>${value}</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
    </dict>
    </plist>
    '';
  }));
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
    ];
    taps = [
      "homebrew/cask"
    ];
    cleanup = "zap";
  };

  fonts = {
    enableFontDir = true;
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

  environment.launchAgents = envVarPlist ({
    NIX_PATH = "darwin-config=/Users/yurialbuquerque/.nixpkgs/darwin-configuration.nix:/nix/var/nix/profiles/per-user/root/channels:/Users/yurialbuquerque/.nix-defexpr/channels";
    NIX_PROFILES = "/nix/var/nix/profiles/default /Users/yurialbuquerque/.nix-profile";
    NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    NIX_REMOTE = "daemon";
  });
}
