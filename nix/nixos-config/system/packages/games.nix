{
  config,
  pkgs,
  ...
}: {

  # TODO: Add kernel module https://github.com/medusalix/xone
  # https://github.com/NixOS/nixpkgs/blob/5f9d1bb572e08ec432ae46c78581919d837a90f6/pkgs/os-specific/linux/xone/default.nix

  environment.systemPackages = with pkgs; [
    lutris
  ];

  programs.steam.enable = true;

  hardware.xone.enable = true;
}
