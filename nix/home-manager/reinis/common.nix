{
  config,
  pkgs,
  ...
}: {
  home.username = "reinis";
  home.homeDirectory = "/home/reinis";

  imports = [
    ./config/neovim.nix
  ];

  nixpkgs.overlays = [
    (import ./overlays/mypackages.nix)
    (import (builtins.fetchTarball {
      url = https://github.com/thiagokokada/i3pyblocks/archive/nix-overlay.tar.gz;
    }))
  ];

  home.packages = with pkgs; [
    alejandra
    # diffoscope
    direnv
    emacs
    fd
    feh
    font-awesome
    fzf
    gron
    k9s
    ncdu
    nethogs
    nodePackages.pyright
    nodePackages.typescript-language-server
    git
    git-crypt
    i3pyblocks
    python310Packages.pgsanity
    redshift
    ripgrep
    signal-desktop
    starship
    zathura
    # zutty # fails to start: "E [main.cc:1310] Error: eglGetDisplay() failed"
    # myxow
  ];

  fonts.fontconfig.enable = true;

  programs.bash = {
    # initExtra = ''
    #   # This is probably needed if we want to add extra env variables
    #   # https://discourse.nixos.org/t/home-manager-doesnt-seem-to-recognize-sessionvariables/8488/7
    #   . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
    # '';
    profileExtra = ''
      source ~/.profile.legacy
    '';
    bashrcExtra = ''
      source ~/.bashrc.legacy
    '';
  };

  programs.direnv = {
    enable = true;
    stdlib = builtins.readFile includes/direnvrc;
    nix-direnv.enable = true;
  };

  programs.firefox = {
    # https://nix-community.github.io/home-manager/options.html#opt-programs.firefox.enable
    enable = true;
    profiles.reinis = {
      id = 0;
      name = "Reinis";
      isDefault = true;
      search.default = "DuckDuckGo";
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        bypass-paywalls-clean
      ];
    };
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  # https://nix-community.github.io/home-manager/release-notes.html
  home.stateVersion = "22.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
