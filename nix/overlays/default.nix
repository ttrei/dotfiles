{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  i3pyblocks = inputs.i3pyblocks.overlay;
  neorg = inputs.neorg-overlay.overlays.default;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  # See examples here:
  # https://github.com/Misterio77/nix-config/blob/d39c4bfa163ab6ecccf2affded0a3e5ad4b8cc7b/overlays/default.nix
  modifications = final: prev: {
    bazarr = final.unstable.bazarr;
    # jackett = final.unstable.jackett;
    navidrome = final.unstable.navidrome;
    sonarr = final.unstable.sonarr;
    radarr = final.unstable.radarr.overrideAttrs (oldAttrs: rec {
      version = "4.4.2.6956";
      src = prev.fetchurl {
        url = "https://github.com/Radarr/Radarr/releases/download/v${version}/Radarr.develop.${version}.linux-core-x64.tar.gz";
        sha256 = "sha256-DVVBJC7gGjlF9S3KI0+9kh4EzDEoWsC2jJxD8khbN2c=";
      };
    });

    comma = final.unstable.comma;

    ghostty = inputs.ghostty.packages."x86_64-linux".default;

    jetbrains = final.unstable.jetbrains;

    # need neovim 0.10 for neorg, nixpkgs-24.05 has 0.9
    neovim-unwrapped = final.unstable.neovim-unwrapped;
    vimPlugins = final.unstable.vimPlugins;

    # arcanPackages = prev.arcanPackages.overrideScope' (finalScope: prevScope: {
    #   arcan = prevScope.arcan.overrideAttrs (finalAttrs: prevAttrs: {
    #     version = "923acbe8a132903c978bd5a8d0a8ed5ff2bacbde";
    #     src = final.fetchFromGitHub {
    #       owner = "letoram";
    #       repo = "arcan";
    #       rev = "923acbe8a132903c978bd5a8d0a8ed5ff2bacbde";
    #       hash = "sha256-/buDAfonIJT2SRNqrYShDQVDXHdvKklyPSFXTAK/0NI=";
    #     };
    #     patches = [];
    #   });
    #   durden = prevScope.durden.overrideAttrs (finalAttrs: prevAttrs: {
    #     version = "347dba6da011bbaa70c6edaf82a2d915f4057db3";
    #     src = final.fetchFromGitHub {
    #       owner = "letoram";
    #       repo = "durden";
    #       rev = "347dba6da011bbaa70c6edaf82a2d915f4057db3";
    #       hash = "sha256-iNf7fOzz7mf1CXG5leCenkSTrdCc9/KL8VLw8gUIyKE=";
    #     };
    #   });
    # });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;

      # https://github.com/NixOS/nixpkgs/issues/360592#issuecomment-2513490613
      # TODO: Remove when https://github.com/NixOS/nixpkgs/issues/360592 fixed
      config.permittedInsecurePackages = [
        "aspnetcore-runtime-6.0.36"
        "aspnetcore-runtime-wrapped-6.0.36"
        "dotnet-sdk-6.0.428"
        "dotnet-sdk-wrapped-6.0.428"
      ];

    };
  };
}
