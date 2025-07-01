{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    ./config/neovim.nix
  ];

  nixpkgs = {
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      outputs.overlays.i3pyblocks

      outputs.overlays.neorg

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "reinis";
    homeDirectory = "/home/reinis";
  };

  home.packages = with pkgs; [
    alejandra
    # https://github.com/debauchee/barrier
    # In the future I should use input-leap instead: https://github.com/input-leap/input-leap
    barrier
    bat
    comma
    unstable.delta
    unstable.difftastic
    unstable.devenv
    # diffoscope
    direnv
    emacs
    eza
    fd
    feh
    font-awesome
    fzf
    gron
    htop
    i3
    moreutils
    ncdu
    nethogs
    nload
    nodejs-slim
    nodePackages.typescript-language-server
    git
    git-crypt
    git-when-merged
    i3pyblocks
    openjdk
    pass
    pyright
    python3Packages.python-lsp-server
    python3Packages.pylsp-rope
    ripgrep
    unstable.ripgrep-all
    sd
    shellcheck
    starship
    stylua
    unstable.superhtml
    unstable.uv
    xclip
    zathura
    zed-editor
    zoxide
    # zutty # fails to start: "E [main.cc:1310] Error: eglGetDisplay() failed"
  ];

  fonts.fontconfig.enable = true;

  programs.bash = {
    enable = true;
    # Unlimited history (there's also some config/code in .bashrc.legacy below)
    # https://stackoverflow.com/a/12234989/9124671
    historySize = -1;
    historyFileSize = -1;
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

  programs.atuin = {
    enable = true;
    package = pkgs.unstable.atuin;
    flags = [
      "--disable-up-arrow"
    ];
    enableBashIntegration = true;
    enableNushellIntegration = true;
  };

  programs.direnv = {
    enable = true;
    stdlib = builtins.readFile includes/direnvrc;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
