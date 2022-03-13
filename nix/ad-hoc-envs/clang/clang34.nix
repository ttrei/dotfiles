with import <nixpkgs> {}; {
  myEnv = stdenv.mkDerivation {
    name = "clang";
    buildInputs = [ stdenv clang_34 ];
    hardeningDisable = [ "all" ];
  };
}
