self: super: {
  mylibusb1 = super.callPackage pkgs/mylibusb1 {};
  myxow = super.callPackage pkgs/myxow {};
  # st = super.callPackage pkgs/st-lukesmith { };
  zutty = super.callPackage pkgs/zutty {};
}
