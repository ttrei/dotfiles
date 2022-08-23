{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    clang-tools
    delta
    diffstat
    direnv
    encfs
    fd
    file
    fzf
    gitAndTools.gitFull
    gnupg
    gnupg1compat
    gnutar
    jq
    lua
    lynx
    moreutils
    mplayer
    neovim
    nix-bash-completions
    p7zip
    pandoc
    pass
    pwgen
    python3
    python3Packages.ipython
    ripgrep
    rsync
    shellcheck
    sshfs-fuse
    stow
    traceroute
    tree
    universal-ctags
    unzip
    vim
    wget
    zip
    zutty
  ];

  programs.bash.enableCompletion = true;

  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;
  services.openssh.permitRootLogin = "prohibit-password";

  # services.cron = {
  #   enable = true;
  #   systemCronJobs = [
  #     "*/3 * * * *  root    . /etc/profile && nix-channel --update nixos"
  #     "*/5 * * * *  root    . /etc/profile && nixos-rebuild dry-build > /tmp/upgr.txt 2>&1 && mv /tmp/upgr.txt /var/tmp/upgradable_packages.txt"
  #     "*/2 * * * *  reinis  /home/reinis/bin/get_upgrade_counts.py"
  #   ];
  # };
}
