with import <nixpkgs> { };
{
  myEnv = stdenv.mkDerivation {
    name = "clang";
    buildInputs = [
      stdenv
      clang_35
    ];
    hardeningDisable = [ "all" ];
  };
}
