with import <nixpkgs> {}; {
  myEnv = stdenv.mkDerivation {
    name = "clang";
    buildInputs = [stdenv clang];
    hardeningDisable = ["all"];
  };
}
