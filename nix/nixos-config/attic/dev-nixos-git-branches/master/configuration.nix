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

  nix.binaryCaches = [
    "http://192.168.122.35:80"
    "http://cache.nixos.org/" # fallback if our cache is down
  ];

  nixpkgs.overlays = [
    (import overlays/mypackages.nix)
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev";

  networking.hostName = "reinis-nixos";
  networking.extraHosts = ''
    178.62.54.226  mazais
    192.168.1.205  reinis-pi
  '';

  time.timeZone = "Europe/Riga";

  nixpkgs.config = {
    allowUnfree = true;
  };

  # No passwords! Login only with an authorized keys.
  users.mutableUsers = false;
  users.users.reinis = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/reinis/";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDhpo7VxrrMzX3b8QZJpyApti/0ujjZZP7GdIF+uMc+ymr783Yry4eOgCJTe17PUgz5yCgxFsWUIA7ZASU8Efau2Th/OqbN0w/kj4x2vEPv6Fp8qAv+BEbeKHtBtrRw8CbZe247No+HA6V5W/hJkdy9XWOTQDP8WUUCTtNoX9XVd/+b7AhGf/FP2RuhA52CqsSh9wGVXmIrWONWRaYSyRZgsE/RKjJxm4DogBjIB8tJSAvSfC9c7s/4Zi5JQPQYIk1V48sEyA0LX77wWpe7MLJ4NbYFQSgX525cCkZJb8v2EnDHJmFj9ZS+HxfucmOijVNNuNVKeBjS8GMtQtIr8pK3 reinis@home-desktop-debian"
    ];
  };
  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDhpo7VxrrMzX3b8QZJpyApti/0ujjZZP7GdIF+uMc+ymr783Yry4eOgCJTe17PUgz5yCgxFsWUIA7ZASU8Efau2Th/OqbN0w/kj4x2vEPv6Fp8qAv+BEbeKHtBtrRw8CbZe247No+HA6V5W/hJkdy9XWOTQDP8WUUCTtNoX9XVd/+b7AhGf/FP2RuhA52CqsSh9wGVXmIrWONWRaYSyRZgsE/RKjJxm4DogBjIB8tJSAvSfC9c7s/4Zi5JQPQYIk1V48sEyA0LX77wWpe7MLJ4NbYFQSgX525cCkZJb8v2EnDHJmFj9ZS+HxfucmOijVNNuNVKeBjS8GMtQtIr8pK3 reinis@home-desktop-debian"
    ];
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "18.09";
}
