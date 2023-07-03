{
  config,
  pkgs,
  ...
}: {
  imports = [./cli-base.nix];

  environment.systemPackages = with pkgs; [
    alejandra
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
    lua
    nodePackages.pyright
    nodePackages.typescript-language-server
    pandoc
    python3
    python3Packages.mutagen
    python3Packages.ipython
    stow
    universal-ctags
    unzip
    vim
    zip
  ];
}
