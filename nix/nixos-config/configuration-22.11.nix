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

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
}
