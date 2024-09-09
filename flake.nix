# https://github.com/Misterio77/nix-starter-configs
{
  description = "NixOS and home-manager configuration";

  # TODO: See if I can improve my configuration by following advice in this post:
  #       "Flakes aren't real and cannot hurt you: a guide to using Nix flakes the non-flake way"
  #       https://jade.fyi/blog/flakes-arent-real/

  inputs = {
    # In general, install packages from a release, not from master.
    # If there's a need, you can install a specific package from nixpkgs-unstable.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    # nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:ttrei/nixpkgs/nixos-unstable";
    # nixpkgs-unstable.url = "github:ttrei/nixpkgs/avante-nvim";
    # nixpkgs-unstable.url = "git+file:///home/reinis/nixpkgs?shallow=1";

    # home-manager release must be the same as the nixpkgs used in home-manager.
    home-manager.url = "github:nix-community/home-manager/release-24.05";
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
    # Accessible through 'nix build', 'nix shell', e.g.,
    # nix shell /home/reinis/dotfiles#mypkgs.x86_64-linux.arcanPackages.arcan
    mypkgs = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        import ./nix/pkgs {inherit pkgs;}
    );
    # nixpkgs with your modifications applied
    # nix shell /home/reinis/dotfiles#modified-pkgs.x86_64-linux.arcanPackages.arcan
    modified-pkgs = forAllSystems (
      system:
        import nixpkgs {
          inherit system;
          overlays = [overlays.modifications];
        }
    );
    # Unmodified nixpkgs
    # nix shell /home/reinis/dotfiles#unmodified-pkgs.x86_64-linux.arcanPackages.arcan
    # Probably could have called this "pkgs", but I'm not sure if that could break something.
    unmodified-pkgs = forAllSystems (
      system: nixpkgs.legacyPackages.${system}
    );
    # Devshell for bootstrapping
    # Acessible through 'nix develop'
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
      jupiter = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./nix/nixos/jupiter.nix
        ];
      };
      saturn = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./nix/nixos/saturn.nix
        ];
      };
      saturn-qemu = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./nix/nixos/saturn-qemu.nix
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
          ./nix/home-manager/nixos.nix
        ];
      };
      "reinis@non-nixos" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./nix/home-manager/non-nixos.nix
        ];
      };
      "reinis@jupiter-work" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./nix/home-manager/jupiter-work.nix
        ];
      };
      "reinis@mercury" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./nix/home-manager/mercury.nix
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
