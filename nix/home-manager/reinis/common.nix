{
  config,
  pkgs,
  ...
}: {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "reinis";
  home.homeDirectory = "/home/reinis";

  nixpkgs.overlays = [
    (import overlays/mypackages.nix)
  ];

  home.packages = with pkgs; [
    alejandra
    direnv
    emacs
    fd
    feh
    fzf
    gron
    k9s
    neovim
    nethogs
    nodePackages.pyright
    nodePackages.typescript-language-server
    git
    git-crypt
    python310Packages.pgsanity
    ripgrep
    signal-desktop
    starship
    zathura
    # zutty # fails to start: "E [main.cc:1310] Error: eglGetDisplay() failed"
    # myxow
  ];

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

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
