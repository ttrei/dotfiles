# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = lib.optionals (builtins.pathExists ./custom.nix) [./custom.nix];

  nixpkgs.overlays = [
    (import overlays/mypackages.nix)
    (import (builtins.fetchTarball {
      url = https://github.com/thiagokokada/i3pyblocks/archive/nix-overlay.tar.gz;
    }))
  ];

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Riga";

  nixpkgs.config = {
    allowUnfree = true;
  };

  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # services.cron = {
  #   enable = true;
  #   systemCronJobs = [
  #     "*/3 * * * *  root    . /etc/profile && nix-channel --update nixos"
  #     "*/5 * * * *  root    . /etc/profile && nixos-rebuild dry-build > /tmp/upgr.txt 2>&1 && mv /tmp/upgr.txt /var/tmp/upgradable_packages.txt"
  #     "*/2 * * * *  reinis  /home/reinis/bin/get_upgrade_counts.py"
  #   ];
  # };

  services.printing.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # No passwords! Login only with an authorized keys.
  # users.mutableUsers = false;
  users.users.reinis = {
    uid = 1000;
    isNormalUser = true;
    extraGroups = ["networkmanager" "wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDhpo7VxrrMzX3b8QZJpyApti/0ujjZZP7GdIF+uMc+ymr783Yry4eOgCJTe17PUgz5yCgxFsWUIA7ZASU8Efau2Th/OqbN0w/kj4x2vEPv6Fp8qAv+BEbeKHtBtrRw8CbZe247No+HA6V5W/hJkdy9XWOTQDP8WUUCTtNoX9XVd/+b7AhGf/FP2RuhA52CqsSh9wGVXmIrWONWRaYSyRZgsE/RKjJxm4DogBjIB8tJSAvSfC9c7s/4Zi5JQPQYIk1V48sEyA0LX77wWpe7MLJ4NbYFQSgX525cCkZJb8v2EnDHJmFj9ZS+HxfucmOijVNNuNVKeBjS8GMtQtIr8pK3 reinis@home-desktop-debian"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC5SV9eWOEcf37wKPqz0G/2kwtd7Xpi/JkkjP8sZR324+J7ItxIxlD7Q9KHBS5VgVQZm0sIm/mmJfUHs5L4bWxgXLDBOGOojm2jpq16FFG3GIFd+8w3oPZ7KX1ivczAzZsm/ehrKxkApTTaicD5iZppNErppZXhwvehpcuqlh5rMgHLU0uphnAR/3euc7GRa2es97mHSHukBMe1zxoa+sZF4aWnMDVeRFmi04xE5dr2235vnL++16ObRUXmTLKfK/JnnkHY9neRdq56WcG28swa2w60wo8Y5ebAyt3l9FVY1yn1FmgI4alDpXzkE/rNkqKY4Uim6tYoMooCAXtaNVmkkmOpuD7Y96oPV9qiVez61OazXW3tcwsV9OMI9FSr4smVo9TQsnzQXDWpoRPSqmLFoFDvEd7Mdl34EzmZs61Kt99CKgUEKk1UfN7DTdlbjKb+qMSM1zHLWqdHkM5z2GVgfuFAJjW+MUyjbvlL4eZlTr4+FcT2qMjpHJY82CCB4RE= reinis@home-desktop-nixos"
    ];
    # mkpasswd -m sha-512
    hashedPassword = "$6$Cg9okSaCqojkhWfc$/EOP6PeEaL5DPnjjNtG7k7.80O5X8Sc4Q2qiTQzS1n6vn.DTp3fI5dafofJzbU/MwFTnroSMg3CT8towxuUwG.";
  };

  programs.gnupg.agent = {
     enable = true;
     pinentryFlavor = "gtk2";
     enableSSHSupport = true;
  };

  programs.bash.enableCompletion = true;

  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;
  services.openssh.permitRootLogin = "prohibit-password";

  systemd.user.services.deduplicate-bash-history = let
    deduplication-script = ./bin/deduplicate-bash-history.py;
  in {
    enable = true;
    path = [ pkgs.python3 ];
    script = "${deduplication-script} ~/.bash_eternal_history";
  };

  systemd.user.timers.deduplicate-bash-history = {
    enable = true;
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "5m";
      Unit = "deduplicate-bash-history.service";
    };
  };

  # networking.extraHosts =
  #   ''
  #     159.65.84.88 foodbook.taukulis.lv
  #   '';

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
