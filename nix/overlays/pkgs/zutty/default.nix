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
  version = "0.13.0-patch-reinis";

  src = fetchgit {
    # url = "https://github.com/tomszilagyi/zutty.git";
    url = "https://github.com/ttrei/zutty.git";
    rev = "c8e4c458fa34d3b79aa7757be51303ff3367ab65";
    hash = "sha256-Gvnh9lxO2Z0rRy+ADGBV66QVI54MUdX1RYVXzMdqW3U=";
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
