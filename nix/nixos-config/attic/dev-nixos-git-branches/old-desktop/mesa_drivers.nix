{
  config,
  pkgs,
  ...
}: {
  nixpkgs.config = {
    packageOverrides = super: let
      self = super.pkgs;
    in {
      # Enable non-free texture floats to be compliant with more recent OpenGL version
      mesa_drivers = self.mesaDarwinOr (
        let
          mo = self.mesa_noglu.override {
            enableTextureFloats = true;
          };
        in
          mo.drivers
      );
    };
  };
}
