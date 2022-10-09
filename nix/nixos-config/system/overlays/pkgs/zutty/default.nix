{
  lib,
  stdenv,
  fetchgit,
  wafHook,
  pkg-config,
  freetype,
  python3,
  glew-egl,
  xorg,
}:
stdenv.mkDerivation rec {
  pname = "zutty";
  version = "0.13.0";

  src = fetchgit {
    url = "https://github.com/tomszilagyi/zutty.git";
    rev = "b7bc75148a0a15eda4f9b5437941949cf72ef5bd";
    hash = "sha256-1eB5GDhWGwyhiKzxpepzjQ44Co0ZeL9JJI5ppPE1TJw=";
    fetchSubmodules = false;
  };

  nativeBuildInputs = [
    wafHook
    pkg-config
    freetype
    python3
    glew-egl
    xorg.libXmu
    xorg.libX11
    xorg.libXft
  ];
  buildInputs = [
  ];
}
