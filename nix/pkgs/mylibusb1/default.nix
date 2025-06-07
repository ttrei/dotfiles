{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  autoreconfHook,
  pkg-config,
  enableUdev ? stdenv.isLinux && !stdenv.hostPlatform.isMusl,
  udev,
  withStatic ? false,
}:
stdenv.mkDerivation rec {
  pname = "mylibusb";
  version = "1.0.25";

  src = fetchFromGitHub {
    owner = "libusb";
    repo = "libusb";
    rev = "v${version}";
    sha256 = "sha256-9ha22rlHFCrWYvcYKYAUlMC4aWMElDAgUPMxKePzPJA=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];
  propagatedBuildInputs = lib.optional enableUdev udev;

  dontDisableStatic = withStatic;

  configureFlags = lib.optional (!enableUdev) "--disable-udev";

  preFixup = lib.optionalString enableUdev ''
    sed 's,-ludev,-L${lib.getLib udev}/lib -ludev,' -i $out/lib/libusb-1.0.la
  '';

  meta = with lib; {
    homepage = "https://libusb.info/";
    repositories.git = "https://github.com/libusb/libusb";
    description = "cross-platform user-mode USB device library";
    longDescription = ''
      libusb is a cross-platform user-mode library that provides access to USB devices.
    '';
    platforms = platforms.all;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ prusnak ];
  };
}
