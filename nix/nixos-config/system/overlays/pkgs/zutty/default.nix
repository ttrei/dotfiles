{
  lib,
  stdenv,
  fetchgit,
  wafHook,
  pkg-config,
  freetype,
  python3,
  glew-egl,
  xorg
}:

stdenv.mkDerivation rec {
  pname = "zutty";
  version = "0.8.0";

  src = fetchgit {
    url = "https://github.com/tomszilagyi/zutty.git";
    rev = "0e88a1072616fb214bc442dd238c3119e61c7e0b";
    sha256 = "17qh8ll70pl7i2wzajdap2f3y8srqpshdxy2x4bni2cgyvbqwk39";
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
