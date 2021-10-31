{
  stdenv,
  wafHook,
  pkg-config,
  freetype,
  python3,
  glew-egl,
  xorg
}:

with stdenv.lib;

stdenv.mkDerivation rec {
  pname = "zutty";
  version = "0.8.0";

  src = fetchgit {
    url = "https://github.com/tomszilagyi/zutty.git";
    rev = "e2a59d5521775042eda2fa64bfc847fc388df6c2";
    sha256 = "16kn6rbpd327bl3d4m3k4pc8qzndb1c07sndsprr25mhp3lcmxcn";
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
