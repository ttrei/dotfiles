{
  stdenv,
  fetchgit,
  pkgconfig,
  writeText,
  libX11,
  ncurses,
  libXft,
  conf ? null,
  patches ? [ ],
  extraLibs ? [ ],
}:
with stdenv.lib;
stdenv.mkDerivation rec {
  name = "st-0.8.2-lukesmith";

  src = fetchgit {
    url = "https://github.com/LukeSmithxyz/st.git";
    rev = "e2a59d5521775042eda2fa64bfc847fc388df6c2";
    sha256 = "16kn6rbpd327bl3d4m3k4pc8qzndb1c07sndsprr25mhp3lcmxcn";
    fetchSubmodules = false;
  };

  inherit patches;

  configFile = optionalString (conf != null) (writeText "config.def.h" conf);
  preBuild = optionalString (conf != null) "cp ${configFile} config.def.h";

  nativeBuildInputs = [
    pkgconfig
    ncurses
  ];
  buildInputs = [
    libX11
    libXft
  ] ++ extraLibs;

  installPhase = ''
    TERMINFO=$out/share/terminfo make install PREFIX=$out
  '';

  meta = {
    homepage = "https://github.com/LukeSmithxyz/st";
    description = "Luke's fork of the suckless simple terminal (st) with vim bindings and Xresource compatibility";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
