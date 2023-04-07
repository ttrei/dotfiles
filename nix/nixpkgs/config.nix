# TODO: Do I need this config when I have flake-based NixOS and home-manager config?
{
  allowUnfree = true;

  # NOTE: I think this was needed only for home-manager-based firefox.
  # packageOverrides = pkgs: {
  #   nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
  #     inherit pkgs;
  #   };
  # };
}
