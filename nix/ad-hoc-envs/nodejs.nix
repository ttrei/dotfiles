with import <nixpkgs> { };
stdenv.mkDerivation {
  name = "nodejs";
  buildInputs = [
    nodejs-10_x
  ];
  src = null;
  shellHook = ''
    export PATH=$HOME/.npm-global/bin:$PATH
  '';
}
