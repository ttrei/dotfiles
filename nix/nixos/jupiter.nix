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
    ./common.nix
    ./hardware-configurations/jupiter.nix
    ./packages/audio.nix
    ./packages/cli.nix
    # ./packages/gamedev.nix
    # ./packages/games.nix
    ./packages/gui.nix
    ./wayland.nix
    ./users/reinis.nix
  ];

  networking.hostName = "jupiter";

  environment.systemPackages = with pkgs; [
    beets

    # zed-editor
    # unstable.aider-chat-full

    qemu_kvm
    jetbrains.idea
    jetbrains.pycharm

    # kdePackages.kdenlive

    # (wrapOBS {
    #   plugins = with obs-studio-plugins; [
    #     advanced-scene-switcher
    #   ];
    # })

    # (kodi.withPackages (
    #   kodiPackages: with kodiPackages; [
    #     inputstream-adaptive
    #     inputstream-ffmpegdirect
    #     inputstreamhelper
    #     inputstream-rtmp
    #     jellyfin
    #   ]
    # ))

  ];

  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      # sudo mkdir -p /media/storage-new/docker-cache
      # sudo chown root:root /media/storage-new/docker-cache
      # sudo chmod 710 /media/storage-new/docker-cache
      data-root = "/media/storage-new/docker-cache";
    };
  };

  # # Not using rottless docker -  had a problem where devcontainer bind mounted
  # # files had root:root permissions in the container.
  # # Apparently that's a pain point in rootless docker.
  # virtualisation.docker = {
  #   enable = false;
  #   rootless = {
  #     enable = true;
  #     setSocketVariable = true;
  #   };
  # };

  services.pulseaudio.enable = false;

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

  services.redshift.enable = true;
  location = {
    provider = "manual";
    # Sigulda
    latitude = 57.15;
    longitude = 24.86;
  };

  # Printing (Brother HL-L2340DW)
  # http://localhost:631/admin -> Find New Printers -> Add This Printer -> Continue -> Make = Generic -> Continue ->
  # Model = IPP Everywhere -> Add Printer
  # 2024-09-26: Disabled to avoid https://www.evilsocket.net/2024/09/26/Attacking-UNIX-systems-via-CUPS-Part-I/
  # 2025-12-30: Enabled to print some documents, didn't work - printing from firefox hanged firefox.
  # services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
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
