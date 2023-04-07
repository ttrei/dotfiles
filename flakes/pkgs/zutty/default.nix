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
  version = "0.13.0-2022-12-30";
  # version = "0.13.0-patch-reinis";

  src = fetchgit {
    url = "https://github.com/tomszilagyi/zutty.git";
    # url = "https://github.com/ttrei/zutty.git";
    rev = "53319956858f6146d78910fa4fcbf3a944eae35b";
    hash = "sha256-baUuKsiD7oiZFUqnNzTKxwKMlac1ZLMX5yOKx/vFgz4=";
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
