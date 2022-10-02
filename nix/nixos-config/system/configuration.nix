# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./base.nix
    ./gui.nix
  ];

  nixpkgs.overlays = [
    (import overlays/mypackages.nix)
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/vda";

  networking.hostName = "nixos-qemu";
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

  services.printing.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # No passwords! Login only with an authorized keys.
  # users.mutableUsers = false;
  users.users.reinis = {
    uid = 1000;
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDhpo7VxrrMzX3b8QZJpyApti/0ujjZZP7GdIF+uMc+ymr783Yry4eOgCJTe17PUgz5yCgxFsWUIA7ZASU8Efau2Th/OqbN0w/kj4x2vEPv6Fp8qAv+BEbeKHtBtrRw8CbZe247No+HA6V5W/hJkdy9XWOTQDP8WUUCTtNoX9XVd/+b7AhGf/FP2RuhA52CqsSh9wGVXmIrWONWRaYSyRZgsE/RKjJxm4DogBjIB8tJSAvSfC9c7s/4Zi5JQPQYIk1V48sEyA0LX77wWpe7MLJ4NbYFQSgX525cCkZJb8v2EnDHJmFj9ZS+HxfucmOijVNNuNVKeBjS8GMtQtIr8pK3 reinis@home-desktop-debian"
    ];
    # mkpasswd -m sha-512
    hashedPassword = "$6$Cg9okSaCqojkhWfc$/EOP6PeEaL5DPnjjNtG7k7.80O5X8Sc4Q2qiTQzS1n6vn.DTp3fI5dafofJzbU/MwFTnroSMg3CT8towxuUwG.";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

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
  system.stateVersion = "22.05"; # Did you read the comment?
}
