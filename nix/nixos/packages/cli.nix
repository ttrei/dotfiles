{
  config,
  pkgs,
  ...
}: {
  imports = [./cli-base.nix];

  environment.systemPackages = with pkgs; [
    alejandra
    beancount
    unstable.beets
    clang-tools
    diffoscope
    diffstat
    emacs
    encfs
    feh
    ffmpeg
    gitAndTools.gitFull
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
    nodePackages.pyright
    nodePackages.typescript-language-server
    pandoc
    python3Packages.mutagen
    python3Packages.ipython
    stow
    universal-ctags
    unzip
    vim
    zip
  ];
}
