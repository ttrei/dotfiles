{ pkgs
, lib
, kernel ? pkgs.linux
}:

pkgs.stdenv.mkDerivation {
  pname = "mt7921-kernel-module";
  inherit (kernel) src version postPatch nativeBuildInputs;

  kernel_dev = kernel.dev;
  kernelVersion = kernel.modDirVersion;

  modulePath = "drivers/net/wireless/mediatek/mt76/mt7921";

  buildPhase = ''
    BUILT_KERNEL=$kernel_dev/lib/modules/$kernelVersion/build

    cp $BUILT_KERNEL/Module.symvers .
    cp $BUILT_KERNEL/.config        .
    cp $kernel_dev/vmlinux          .

    make "-j$NIX_BUILD_CORES" modules_prepare
    make "-j$NIX_BUILD_CORES" M=$modulePath modules
  '';

  installPhase = ''
    make \
      INSTALL_MOD_PATH="$out" \
      XZ="xz -T$NIX_BUILD_CORES" \
      M="$modulePath" \
      modules_install
  '';

  patches = [ ./spinlock-fix.patch ];

  meta = {
    description = "MediaTek MT7921 kernel module";
    license = lib.licenses.isc;
  };
}
