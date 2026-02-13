{
  config,
  pkgs,
  ...
}:
{
  imports = [ ./cli-base.nix ];

  environment.systemPackages = with pkgs; [
    alejandra
    beancount
    clang-tools
    # diffoscope
    diffstat
    emacs
    encfs
    eza
    feh
    ffmpeg
    gitFull
    git-crypt
    gron
    htop
    imagemagick
    jmtpfs
    jq
    k9s
    # 2024-09-22: build failed
    # linuxPackages_latest.perf
    lua
    nodePackages.typescript-language-server
    pandoc
    pyright
    python3Packages.mutagen
    python3Packages.ipython
    ruff
    steam-run
    stow
    universal-ctags
    unzip
    vim
    zip
  ];
}
