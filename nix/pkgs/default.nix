# Custom packages
# Can build them manually with 'nix build .#example' or (legacy) 'nix-build -A example'
{pkgs ? (import ../nixpkgs.nix) {}}: {
  # st = pkgs.callPackage ./st-lukesmith { };
  zutty = pkgs.callPackage ./zutty {};
  arcanPackages = pkgs.recurseIntoAttrs (pkgs.callPackage ./arcan {});

  mt7921-kernel-module = pkgs.callPackage ./mt7921 {};
  # TODO: how to pull in "config" here?
  #       not needed unless you want to boot a non-default kernel
  # mt7921-kernel-module = pkgs.callPackage ./mt7921 {
  #   # Make sure the module targets the same kernel as your system is using.
  #   kernel = config.boot.kernelPackages.kernel;
  # };


}
