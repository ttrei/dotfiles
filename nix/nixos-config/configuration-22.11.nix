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

  users.mutableUsers = false;

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
    path = [pkgs.python3];
    script = "${deduplication-script} ~/.bash_eternal_history";
  };

  systemd.user.timers.deduplicate-bash-history = {
    enable = true;
    wantedBy = ["timers.target"];
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
