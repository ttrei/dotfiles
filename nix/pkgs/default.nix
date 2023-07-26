# Custom packages
# Can build them manually with 'nix build .#example' or (legacy) 'nix-build -A example'
{pkgs ? (import ../nixpkgs.nix) {}}: {
  # st = pkgs.callPackage ./st-lukesmith { };
  zutty = pkgs.callPackage ./zutty {};
}
