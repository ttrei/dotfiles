rec {
  description = "Home Manager configurations";

  inputs = {
    nixpkgs.url = "flake:nixpkgs";
    homeManager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    libusb.url = "github:steav005/xow/0fe9cd9";
  };

  outputs = { self, nixpkgs, homeManager, libusb }: {

    homeConfigurations = {
      "reinis" = homeManager.lib.homeManagerConfiguration {
        configuration = import ./home.nix;

        system = "x86_64-linux";
        # Home Manager needs a bit of information about you and the
        # paths it should manage.
        username = "reinis";
        homeDirectory = "/home/reinis";
        # This value determines the Home Manager release that your
        # configuration is compatible with. This helps avoid breakage
        # when a new Home Manager release introduces backwards
        # incompatible changes.
        #
        # You can update Home Manager without changing this value. See
        # the Home Manager release notes for a list of state version
        # changes in each release.
        stateVersion = "22.05";
      };
    };
  };
}
