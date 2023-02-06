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

  # Attempt #1
  # https://discourse.nixos.org/t/printers-they-work/17545
  services.printing.browsing = true;
  services.printing.browsedConf = ''
  BrowseDNSSDSubTypes _cups,_print
  BrowseLocalProtocols all
  BrowseRemoteProtocols all
  CreateIPPPrinterQueues All

  BrowseProtocols all
      '';
  services.avahi = {
    enable = true;
    nssmdns = true;
  };
  # Printer test page doesn't print.
  # Sample document doesn't print.
  # Printer status in http://localhost:631/printers/:
  # Paused - "No destination host name supplied by cups-browsed for printer "Brother_HL_L2340D_series", is cups-browsed running?"
  # Tried to enable cups-browsed explicitly but systemctl status cups-browsed.service shows
  # Feb 06 21:57:22 home-desktop-nixos systemd[1]: Started CUPS Remote Printer Discovery.
  # Feb 06 21:57:22 home-desktop-nixos systemd[1]: cups-browsed.service: Deactivated successfully.
  systemd.services.cups-browsed.enable = true;

  # Attempt #2
  # https://discourse.nixos.org/t/brother-dcp-572dw-wrapper/8113
  # hardware.printers =
  #   let
  #     brother = "Brother_HL-L2340DW_NixOS";
  #     # hostName = "printer.lan";
  #     hostName = "192.168.1.215";
  #   in
  #   {
  #       ensureDefaultPrinter = brother;
  #       ensurePrinters = [
  #         {
  #           name = brother;
  #           deviceUri = "ipp://${hostName}/ipp";
  #           model = "everywhere";
  #           description = lib.replaceStrings [ "_" ] [ " " ] brother;
  #           location = "Bedroom";
  #         }
  #       ];
  #   };
  # Printer test page doesn't print.
  # Sample document (1 page) prints as many blank pages.

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
  services.openssh.settings = {
    passwordAuthentication = false;
    permitRootLogin = "prohibit-password";
  };

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
