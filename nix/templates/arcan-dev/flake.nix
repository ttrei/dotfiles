# Originally shared by cipharius in arcan discord:
# https://discord.com/channels/830752623765749780/830752623765749783/1147240223575658517
{
  description = "arcan development environment";

  inputs = {
    ttrei.url = "github:ttrei/dotfiles";
    # Use a local copy (useful when making changes in dotfiles):
    # ttrei.url = "path:/home/reinis/dotfiles";
  };

  outputs = {
    self,
    ttrei,
  }: let
    default_system = "x86_64-linux";
    pkgs = ttrei.nixpkgs.legacyPackages.${default_system};
  in {
    devShell.${default_system} = pkgs.mkShell {
      nativeBuildInputs = with pkgs; [
        cmake
        gnumake
        pkgconfig
        freetype.dev
        sqlite.dev
        mesa.dev
        mesa_glu.dev
        openal
        SDL2.dev
        libxkbcommon
        libusb
      ];

      hardeningDisable = ["all"];
    };
  };
}
