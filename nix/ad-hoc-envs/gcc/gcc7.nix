with import <nixpkgs> { };
{
  myEnv = stdenv.mkDerivation {
    name = "gcc";
    buildInputs = [
      stdenv
      gcc7
    ];
  };
}
