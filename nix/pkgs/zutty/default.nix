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
  version = "0.14.0-2023-09-24";
  # version = "0.13.0-patch-reinis";

  src = fetchgit {
    url = "https://github.com/tomszilagyi/zutty.git";
    # url = "https://github.com/ttrei/zutty.git";
    rev = "1ff6da9b37c1e641610dd6918791ee863b35d2e0";
    hash = "sha256-PsubFOKs29LHfqPihBSB9V73HWSNTAUR8kR/cd6OcVQ=";
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
