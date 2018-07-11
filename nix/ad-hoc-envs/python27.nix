with import <nixpkgs> {}; {
  sdlEnv = stdenv.mkDerivation {
    name = "python2.7";
    buildInputs = [
      stdenv
      python27Packages.ipython
      python27Packages.matplotlib
    ];
  };
}
