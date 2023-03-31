{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configurations/qemu.nix
    ./packages/cli.nix
    ./packages/gui.nix
    ./packages/htpc.nix
    ./packages/games.nix
    ./users/user.nix
    ./users/reinis.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/vda";

  networking.hostName = "htpc-nixos";

  services.transmission.enable = true;
  services.transmission.settings = {
    dht-enabled = true;
    download-queue-enabled = true;
    download-queue-size = 20;
    encryption = 0;
    peer-limit-global = 500;
    peer-limit-per-torrent = 50;
    peer-port = 60465;
    pex-enabled = true;
    port-forwarding-enabled = true;
    preallocation = 1;
    prefetch-enabled = true;
    ratio-limit = 3;
    ratio-limit-enabled = true;
    rpc-authentication-required = true;
    rpc-bind-address = "0.0.0.0";
    rpc-enabled = true;
    rpc-host-whitelist = "";
    rpc-host-whitelist-enabled = true;
    rpc-password = "{828146cc3a506cfd5b9beb8c8e3a4cb92b17813bT22fz9tj";
    rpc-port = 9091;
    rpc-url = "/transmission/";
    rpc-username = "user";
    rpc-whitelist = "192.168.*.* 127.0.0.1";
    rpc-whitelist-enabled = true;
  };
}
