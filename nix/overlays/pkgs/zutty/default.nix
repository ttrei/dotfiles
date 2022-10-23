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
    url = "ssh://reinis@taukulis.lv:/home/reinis/gitrepos/zutty.git";
    rev = "c8e4c458fa34d3b79aa7757be51303ff3367ab65";
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
