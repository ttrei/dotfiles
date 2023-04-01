{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    delta
    direnv
    fd
    file
    fzf
    git
    gnupg
    gnupg1compat
    gnutar
    lynx
    moreutils
    neovim
    nethogs
    nix-bash-completions
    p7zip
    pass
    pwgen
    ripgrep
    rsync
    shellcheck
    sshfs-fuse
    starship
    tmux
    traceroute
    tree
    usbutils
    wget
  ];
}
