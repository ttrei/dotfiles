{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  disabledModules = [
    # "services/audio/navidrome.nix"
    "services/misc/bazarr.nix"
    "services/misc/jackett.nix"
    "services/misc/servarr/radarr.nix"
    "services/misc/servarr/sonarr.nix"
  ];

  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # "${inputs.nixpkgs-unstable}/nixos/modules/services/audio/navidrome.nix"
    "${inputs.nixpkgs-unstable}/nixos/modules/services/misc/bazarr.nix"
    "${inputs.nixpkgs-unstable}/nixos/modules/services/misc/jackett.nix"
    "${inputs.nixpkgs-unstable}/nixos/modules/services/misc/servarr/radarr.nix"
    "${inputs.nixpkgs-unstable}/nixos/modules/services/misc/servarr/sonarr.nix"
  ];

  nixpkgs = {
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      outputs.overlays.i3pyblocks

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];

    config = {
      allowUnfree = true;

      # https://github.com/NixOS/nix/issues/2982#issuecomment-2477618346
      nix.channel.enable = false;

      # NOTE: I think this was needed only for home-manager-based firefox.
      # packageOverrides = pkgs: {
      #   nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      #     inherit pkgs;
      #   };
      # };

    };
  };

  nix = {
    # This will add each flake input as a registry
    # To make nix commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      # NOTE (2024-01-21): The substituter logic currently has a bug that is being worked on
      # https://github.com/NixOS/nix/issues/6901
      # https://github.com/NixOS/nix/pull/8983
      substituters = [
        # "http://pluto.local:8088"
        "https://devenv.cachix.org"
      ];
      trusted-users = [ "reinis" ];
    };
  };

  time.timeZone = "Europe/Riga";

  i18n.defaultLocale = "en_US.UTF-8";

  users.mutableUsers = false;

  # https://github.com/NixOS/nixpkgs/issues/160923
  # https://github.com/NixOS/nixpkgs/pull/197118
  # https://github.com/NixOS/nixpkgs/pull/243834
  # xdg.portal = {
  #   enable = true;
  #   xdgOpenUsePortal = true;
  #   extraPortals = [pkgs.xdg-desktop-portal-gtk];
  # };

  xdg.mime.defaultApplications = {
    "application/pdf" = "firefox.desktop";
    "inode/directory" = "thunar.desktop";
    "text/html" = "firefox.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/ftp" = "firefox.desktop";
    "x-scheme-handler/chrome" = "firefox.desktop";
    "x-scheme-handler/about" = "firefox.desktop";
    "x-scheme-handler/unknown" = "firefox.desktop";
    "application/x-extension-htm" = "firefox.desktop";
    "application/x-extension-html" = "firefox.desktop";
    "application/x-extension-shtml" = "firefox.desktop";
    "application/xhtml+xml" = "firefox.desktop";
    "application/x-extension-xhtml" = "firefox.desktop";
    "application/x-extension-xht" = "firefox.desktop";
  };

  documentation = {
    enable = true;
    man.enable = true;
    dev.enable = true;
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.bash.completion.enable = true;

  # programs.nix-ld.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
    extraConfig = "
      TrustedUserCAKeys /etc/ssh/trusted_ca_keys.pub
      HostCertificate /etc/ssh/ssh_host_rsa_key-cert.pub
    ";
  };

  networking.networkmanager.enable = true;
  # Connect to a wireless connection:
  # $ nmcli device wifi connect <your SSID> password <your password>
  # TODO: Manage wireless connections declaratively

  networking.extraHosts = builtins.readFile ./hosts;

  networking.firewall.enable = true;
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
}
