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
    fzf
    gron
    lorri
    neovim
    git
    git-crypt
    ripgrep
    signal-desktop
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
