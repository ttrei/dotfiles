with import <nixpkgs> {}; {
  sdlEnv = stdenv.mkDerivation {
    name = "picard";
    buildInputs = [stdenv sshfsFuse picard];
  };
}
