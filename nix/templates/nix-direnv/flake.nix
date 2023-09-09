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
    in {
      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.bashInteractive
          # mypkgs.zutty
        ];
      };
    });
}
