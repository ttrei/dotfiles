{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./common.nix
    ./hardware-configurations/jupiter.nix
    ./packages/audio.nix
    ./packages/cli.nix
    ./packages/games.nix
    ./packages/gui.nix
    ./users/reinis.nix
  ];

  networking.hostName = "jupiter";

  networking.firewall.allowedTCPPorts = [
    24800 # barrier
  ];

  environment.systemPackages = with pkgs; [
    qemu_kvm
    arcanPackages.arcan
    # TODO: cannot launch durden because the nix store path contains "-" characters, arcan forbids those
    arcanPackages.durden
    vscode-fhs
  ];

  virtualisation.docker.enable = true;

  # https://discourse.nixos.org/t/state-of-jackd-in-nixos/6007/14
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    jack.enable = true;
    pulse.enable = true;
  };

  # Printing (Brother HL-L2340DW)
  # http://localhost:631/admin -> Find New Printers -> Add This Printer -> Continue -> Make = Generic -> Continue ->
  # Model = IPP Everywhere -> Add Printer
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns = true;
    openFirewall = true;
  };

  # services.cron = {
  #   enable = true;
  #   systemCronJobs = [
  #     "*/3 * * * *  root    . /etc/profile && nix-channel --update nixos"
  #     "*/5 * * * *  root    . /etc/profile && nixos-rebuild dry-build > /tmp/upgr.txt 2>&1 && mv /tmp/upgr.txt /var/tmp/upgradable_packages.txt"
  #     "*/2 * * * *  reinis  /home/reinis/bin/get_upgrade_counts.py"
  #   ];
  # };

  # networking.extraHosts =
  #   ''
  #     159.65.84.88 foodbook.taukulis.lv
  #   '';

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
