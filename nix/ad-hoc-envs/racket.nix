with import <nixpkgs> {}; {
  sdlEnv = stdenv.mkDerivation {
    name = "racket";
    buildInputs = [
      stdenv
      pltScheme
    ];
  };
}
