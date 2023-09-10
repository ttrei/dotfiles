{
  description = "devShell using packages, overlays, etc. from ttrei dotfiles";
  inputs.ttrei.url = "github:ttrei/dotfiles";
  # Use a local copy (useful when making changes in dotfiles):
  # inputs.ttrei.url = "path:/home/reinis/dotfiles";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, ttrei, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = ttrei.nixpkgs.legacyPackages.${system};
      mypkgs = ttrei.mypkgs.${system};
    in rec {
      # Expose the used packages as flake output, so you can enter their build environment like this:
      #   nix develop .#zutty
      # The output must be named "packages" for "nix develop" to recognize it.
      packages = {
        zutty = mypkgs.zutty;
      };
      devShells.default = pkgs.mkShell {
        packages = [ pkgs.bashInteractive ] ++ pkgs.lib.attrsets.mapAttrsToList (name: value: value) packages;
      };
    });
}
