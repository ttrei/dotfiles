# https://github.com/Misterio77/nix-starter-configs
{
  description = "NixOS and home-manager configuration";

  inputs = {
    # In general, install packages from a release, not from master.
    # If there's a need, you can install a specific package from nixpkgs-unstable.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # home-manager release must be the same as the nixpkgs used in home-manager.
    home-manager.url = "github:nix-community/home-manager/release-23.05";
    # You can change this to "nixpkgs-unstable" to use latest home-manager.
    # Then you also have to change nixpkgs to nixpkgs-unstable in homeConfigurations below.
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    i3pyblocks.url = "github:thiagokokada/i3pyblocks";

    # https://github.com/nvim-neorg/nixpkgs-neorg-overlay
    neorg-overlay.url = "github:nvim-neorg/nixpkgs-neorg-overlay";

    # hardware.url = "github:nixos/nixos-hardware";

    # Shameless plug: looking for a way to nixify your themes and make
    # everything match nicely? Try nix-colors!
    # nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
  in rec {
    inherit nixpkgs;
    inherit nixpkgs-unstable;
    # Your custom packages
    # Acessible through 'nix build', 'nix shell', etc
    mypkgs = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        import ./nix/pkgs {inherit pkgs;}
    );
    # Devshell for bootstrapping
    # Acessible through 'nix develop' or 'nix-shell' (legacy)
    devShells = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        import ./nix/shell.nix {inherit pkgs;}
    );

    # Your custom packages and modifications, exported as overlays
    overlays = import ./nix/overlays {inherit inputs;};
    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./nix/modules/nixos;
    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ./nix/modules/home-manager;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild switch --flake .#your-hostname'
    nixosConfigurations = {
      home-desktop-nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./nix/nixos/home-desktop.nix
        ];
      };
      kodi = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./nix/nixos/htpc.nix
        ];
      };
      htpc-qemu = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./nix/nixos/htpc-qemu.nix
        ];
      };
      nixos-qemu = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./nix/nixos/qemu-base.nix
        ];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager switch --flake .#reinis@nixos'
    homeConfigurations = {
      "reinis@nixos" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./nix/home-manager/home-nixos.nix
        ];
      };
      "reinis@non-nixos" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./nix/home-manager/home-non-nixos.nix
        ];
      };
    };

    templates = {
      nix-direnv = {
        path = ./nix/templates/nix-direnv;
        description = "nix flake new -t github:ttrei/dotfiles#nix-direnv .";
      };
      arcan-dev = {
        path = ./nix/templates/arcan-dev;
        description = "nix flake new -t github:ttrei/dotfiles#arcan-dev .";
      };
    };
  };
}
