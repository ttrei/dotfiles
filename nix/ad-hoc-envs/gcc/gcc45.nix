with import <nixpkgs> { };
{
  myEnv = stdenv.mkDerivation {
    name = "gcc";
    buildInputs = [
      stdenv
      gcc45
    ];
    hardeningDisable = [ "all" ];
  };
}
