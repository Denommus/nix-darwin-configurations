{ config, pkgs, ... }:
let myAspell = pkgs.aspellWithDicts (d: [d.en d.pt_BR]);
in {
  programs.emacs.init = import emacs/emacs.nix { inherit pkgs; };
  programs.emacs.enable = true;
  services.emacs.client.enable = true;
  programs.emacs.package = pkgs.stdenv.mkDerivation rec {
    pname = "emacs";
    version = "28.1";

    emacsName = "emacs-${version}";
    macportVersion = "9.0";
    name = "emacs-mac-${version}-${macportVersion}";

    src = pkgs.fetchurl {
      url = "mirror://gnu/emacs/${emacsName}.tar.xz";
      sha256 = "sha256-KLGz0JkDegiPCkyiUdfnJi6rXqFneqv/psRCaWGtdeE=";
    };

    macportSrc = pkgs.fetchurl {
      url = "ftp://ftp.math.s.chiba-u.ac.jp/emacs/${emacsName}-mac-${macportVersion}.tar.gz";
      sha256 = "sha256-lUgKu6y4VeqlrrfDvBhvVS85UaoizNlMNp8ujr71/oE=";
      name = "${emacsName}-mac-${macportVersion}.tar.gz";
    };

    hiresSrc = pkgs.fetchurl {
      url = "ftp://ftp.math.s.chiba-u.ac.jp/emacs/emacs-hires-icons-3.0.tar.gz";
      sha256 = "0f2wzdw2a3ac581322b2y79rlj3c9f33ddrq9allj97r1si6v5xk";
    };

    enableParallelBuilding = true;

    nativeBuildInputs = with pkgs; [ pkg-config autoconf automake ];

    buildInputs = with pkgs; with pkgs.darwin.apple_sdk.frameworks; [ ncurses libxml2 gnutls texinfo gettext jansson
                    AppKit Carbon Cocoa IOKit OSAKit Quartz QuartzCore WebKit
                    ImageCaptureCore GSS ImageIO   # may be optional
                  ];

    postUnpack = ''
    mv $sourceRoot $name
    tar xf $macportSrc -C $name --strip-components=1
    mv $name $sourceRoot
    # extract retina image resources
    tar xfv $hiresSrc --strip 1 -C $sourceRoot
    '';

    postPatch = ''
    patch -p1 < patch-mac
    substituteInPlace lisp/international/mule-cmds.el \
      --replace /usr/share/locale ${pkgs.gettext}/share/locale
    # use newer emacs icon
    cp nextstep/Cocoa/Emacs.base/Contents/Resources/Emacs.icns mac/Emacs.app/Contents/Resources/Emacs.icns
    # Fix sandbox impurities.
    substituteInPlace Makefile.in --replace '/bin/pwd' 'pwd'
    substituteInPlace lib-src/Makefile.in --replace '/bin/pwd' 'pwd'
    # Reduce closure size by cleaning the environment of the emacs dumper
    substituteInPlace src/Makefile.in \
      --replace 'RUN_TEMACS = ./temacs' 'RUN_TEMACS = env -i ./temacs'
    '';

    configureFlags = [
      "LDFLAGS=-L${pkgs.ncurses.out}/lib"
      "--with-xml2=yes"
      "--with-gnutls=yes"
      "--with-mac"
      "--with-modules"
      "--enable-mac-app=$$out/Applications"
    ];

    CFLAGS = "-O3";
    LDFLAGS = "-O3 -L${pkgs.ncurses.out}/lib";

    postInstall = ''
    mkdir -p $out/share/emacs/site-lisp/
    cp ${./emacs/site-start.el} $out/share/emacs/site-lisp/site-start.el
    '';

    # fails with:

    # Ran 3870 tests, 3759 results as expected, 6 unexpected, 105 skipped
    # 5 files contained unexpected results:
    #   lisp/url/url-handlers-test.log
    #   lisp/simple-tests.log
    #   lisp/files-x-tests.log
    #   lisp/cedet/srecode-utest-template.log
    #   lisp/net/tramp-tests.log
    doCheck = false;

    meta = with pkgs.lib; {
      description = "The extensible, customizable text editor";
      homepage    = "https://www.gnu.org/software/emacs/";
      license     = licenses.gpl3Plus;
      maintainers = with maintainers; [ jwiegley matthewbauer ];
      platforms   = platforms.darwin;

      longDescription = ''
      GNU Emacs is an extensible, customizable text editor—and more.  At its
      core is an interpreter for Emacs Lisp, a dialect of the Lisp
      programming language with extensions to support text editing.
      The features of GNU Emacs include: content-sensitive editing modes,
      including syntax coloring, for a wide variety of file types including
      plain text, source code, and HTML; complete built-in documentation,
      including a tutorial for new users; full Unicode support for nearly all
      human languages and their scripts; highly customizable, using Emacs
      Lisp code or a graphical interface; a large number of extensions that
      add other functionality, including a project planner, mail and news
      reader, debugger interface, calendar, and more.  Many of these
      extensions are distributed with GNU Emacs; others are available
      separately.
      This is the "Mac port" addition to GNU Emacs 26. This provides a native
      GUI support for Mac OS X 10.6 - 10.12. Note that Emacs 23 and later
      already contain the official GUI support via the NS (Cocoa) port for
      Mac OS X 10.4 and later. So if it is good enough for you, then you
      don't need to try this.
      '';
    };
  };

  home.sessionVariablesExtra = ''
  export EDITOR=emacs
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
