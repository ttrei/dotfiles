{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "reinis";
  home.homeDirectory = "/home/reinis";

  nixpkgs.overlays = [
    (import overlays/mypackages.nix)
  ];

  home.packages = with pkgs; [
    brave
    direnv
    emacs
    fd
    feh
    fzf
    gron
    neovim
    git
    git-crypt
    ripgrep
    signal-desktop
    starship
    vscode-with-extensions
    # myxow
  ];

  programs.bash = {
    # TODO: enable for NixOS deployments
    enable = false;
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
    stdlib = ''
      # https://github.com/direnv/direnv/wiki/Customizing-cache-location
      # Two things to know:
      # * `direnv_layour_dir` is called once for every {.direnvrc,.envrc} sourced
      # * The indicator for a different direnv file being sourced is a different `''$PWD` value
      # This means we can hash `''$PWD` to get a fully unique cache path for any given environment
      : ''${XDG_CACHE_HOME:=''$HOME/.cache}
      declare -A direnv_layout_dirs
      direnv_layout_dir() {
          echo "''${direnv_layout_dirs[$PWD]:=$(
              echo -n "''$XDG_CACHE_HOME"/direnv/layouts/
              echo -n "''$PWD" | sha1sum | cut -d ' ' -f 1
          )}"
      }
    '';
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
