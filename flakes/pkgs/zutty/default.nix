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
  version = "0.14.0-2023-02-18";
  # version = "0.13.0-patch-reinis";

  src = fetchgit {
    url = "https://github.com/tomszilagyi/zutty.git";
    # url = "https://github.com/ttrei/zutty.git";
    rev = "bc6e0893e91bc0ffd08cb7d15727973de450c3d6";
    hash = "sha256-b/q7hIi/U/GkKo+MIFX2wWnHZAy5rQGXNul3I1pxo1Q=";
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
