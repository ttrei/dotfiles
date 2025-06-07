with import <nixpkgs> { };
{
  sdlEnv = stdenv.mkDerivation {
    name = "ffmpeg";
    buildInputs = [
      stdenv
      ffmpeg
    ];
  };
}
