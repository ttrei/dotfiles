with import <nixpkgs> {}; {
  sdlEnv = stdenv.mkDerivation {
    name = "python-neovim";
    buildInputs = [
      stdenv
      python
      python27Packages.ipython
      python27Packages.neovim
    ];
  };
}
